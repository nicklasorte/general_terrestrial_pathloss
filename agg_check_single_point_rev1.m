function [array_agg_check]=agg_check_single_point_rev1(app,data_label1,string_prop_model,mc_percentile,reliability,sim_number,mc_size,single_search_dist,parallel_flag,workers,sim_array_list_bs,base_protection_pts,confidence,FreqMHz,Tpol,norm_aas_zero_elevation_data,radar_beamwidth,min_ant_loss,min_azimuth,max_azimuth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Aggregate Check Function
%%%%%%%%%%First check for the aggregate file
agg_check_file_name=strcat(data_label1,'_',string_prop_model,'_array_agg_check_',num2str(mc_percentile),'_',num2str(min(reliability)),'_',num2str(max(reliability)),'_',num2str(sim_number),'_',num2str(mc_size),'_',num2str(single_search_dist),'km.mat');
[var_exist_agg_check]=persistent_var_exist_with_corruption(app,agg_check_file_name);
if var_exist_agg_check==2
    %%%%%%%%%%%load
    retry_load=1;
    while(retry_load==1)
        try
            load(agg_check_file_name,'array_agg_check')
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%'Calculate the aggregate'
    point_idx=single_search_dist;

    %%%%%%%%%%%%%%%%Pathloss Calculate and Load
    [pathloss]=single_point_pathloss_rev1(app,string_prop_model,point_idx,sim_number,data_label1,parallel_flag,workers,sim_array_list_bs,base_protection_pts,reliability,confidence,FreqMHz,Tpol);
    %server_status_rev2(app,tf_server_status)

    size(sim_array_list_bs)
    size(pathloss)

    %%%%%%%Take into consideration the sector/azimuth off-axis gain
    [bs_azi_gain,~]=off_axis_gain_bs2fed_rev1(app,base_protection_pts,point_idx,sim_array_list_bs,norm_aas_zero_elevation_data);
    %%%%%%array_bs_azi_data --> 1) bs2fed_azimuth 2) sector_azi 3) azi_diff_bs 4) mod_azi_diff_bs 5) bs_azi_gain  %%%%%%%%This is the data to save and export to the excel

    move_list_reliability=reliability;
    [mid_idx]=nearestpoint_app(app,50,move_list_reliability);
    mid_pathloss_dB=pathloss(:,mid_idx);
    temp_pr_dbm=sim_array_list_bs(:,4)-mid_pathloss_dB+bs_azi_gain;  %%%%%%%%%%%Non-Mitigation EIRP - Pathloss + BS Azi Gain = Power Received at Federal System

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Not optimized, but similar to what CBRS does.
    %%%%%%%%%%%%%Quite a bit quicker than the near-opt move list.
    tic;
    [~,sort_bs_idx]=sort(temp_pr_dbm,'descend'); %%%Sort power received at radar, and then this is the order of turn off.
    toc; %%%%%Elapsed time is 0.000862 seconds.

    if any(isnan(sort_bs_idx))
        %disp_progress(app,strcat('Error: PAUSE: Inside Pre_sort_ML rev8 Line 133: NaN Error on sort_bs_idx'))
        pause;
    end

    %%%sort_mid_pr_dBm(1:10)
    tic;
    sort_sim_array_list_bs=sim_array_list_bs(sort_bs_idx,:);
    sort_full_Pr_dBm=sim_array_list_bs(sort_bs_idx,4)-pathloss(sort_bs_idx,:)+bs_azi_gain(sort_bs_idx); %%%%%%%%%%%Non-Mitigation EIRP - Pathloss + BS Azi Gain = Power Received at Federal System
    toc;

    if any(isnan(bs_azi_gain))
        find(isnan(bs_azi_gain))
        %disp_progress(app,strcat('Error: PAUSE: Inside Pre_sort_ML rev8 Line 145: NaN error on bs_azi_gain'))
        pause;
    end

    if any(isnan(pathloss))
        find(isnan(pathloss))
        %disp_progress(app,strcat('Error: PAUSE: Inside Pre_sort_ML rev8 Line 151: NaN error on pathloss'))
        pause;
    end

    if any(isnan(sim_array_list_bs(:,4)))
        find(isnan(sim_array_list_bs(:,4)))
        %disp_progress(app,strcat('Error: PAUSE: Inside Pre_sort_ML rev8 Line 157: NaN error on sim_array_list_bs(:,4)'))
        pause;
    end

    if any(isnan(sort_full_Pr_dBm))
        %sort_full_Pr_dBm
        %find(isnan(sort_full_Pr_dBm(:,1)))
        disp_progress(app,strcat('Error: PAUSE: Inside Pre_sort_ML rev8 Line 164: NaN error on sort_full_Pr_dBm'))
        pause;
    end



    if isempty(sort_full_Pr_dBm)
        array_agg_check=NaN(1,1);
        array_agg_check=array_agg_check(~isnan(array_agg_check));
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%Add Radar Antenna Pattern: Offset from 0 degrees and loss in dB
        if radar_beamwidth==360
            radar_ant_array=vertcat(horzcat(0,0),horzcat(360,0));
            min_ant_loss=0;
        else
            [radar_ant_array]=horizontal_antenna_loss_app(app,radar_beamwidth,min_ant_loss);
            %%%%%%%%%%%Note, this is not STATGAIN
        end

        %%%%%%%%%%%%%%%%Calculate the simualation azimuths
        [array_sim_azimuth,num_sim_azi]=calc_sim_azimuths_rev3_360_azimuths_app(app,radar_beamwidth,min_azimuth,max_azimuth);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Each Base Station Azimuth
        sim_pt=base_protection_pts(point_idx,:);
        bs_azimuth=azimuth(sim_pt(1),sim_pt(2),sort_sim_array_list_bs(:,1),sort_sim_array_list_bs(:,2));

        %%%%%%%%%Need to calculate the off-axis
        %%%%%%%%%gain when we take

        %%%%%%%%Rand Seed1 for MC Iterations and Move List Calculation
        tempx=ceil(rand(1)*mc_size);
        tempy=ceil(rand(1)*mc_size);
        rand_seed1=tempx+tempy;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%Generate MC Iterations and Calculate Move List
        %%%Preallocate
        array_agg_check_mc_dBm=NaN(mc_size,num_sim_azi);
        %[num_tx,~]=size(sort_sim_array_list_bs);
        for mc_iter=1:1:mc_size
            %disp_progress(app,strcat('Inside Pre_sort_ML rev8 Line 236:',num2str(mc_iter)))
            mc_iter
            %%%%%%%Generate 1 MC Iteration
            [sort_monte_carlo_pr_dBm]=monte_carlo_Pr_dBm_rev1_app(app,rand_seed1,mc_iter,move_list_reliability,sort_full_Pr_dBm);


            if length(reliability)==1 %%%%%%%This assume 50%
                if ~all(sort_full_Pr_dBm==sort_monte_carlo_pr_dBm)
                    %disp_progress(app,strcat('Error: Pause: Inside Pre_sort_ML rev8 Line 244:Error:Pr dBm Mismatch'))
                    pause;
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Move List for Single MC Iteration
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%Preallocate
            azimuth_agg_dBm=NaN(num_sim_azi,1);
            for azimuth_idx=1:1:num_sim_azi

                %%%Find CBSD azimuths outside of +/- of half_ant_hor_deg of temp_azimuth
                sim_azimuth=array_sim_azimuth(azimuth_idx);

                %%%%%%%Calculate the loss due to off axis in the horizontal direction
                [off_axis_loss]=calc_off_axix_loss_rev1_app(app,sim_azimuth,bs_azimuth,radar_ant_array,min_ant_loss);
                sort_temp_mc_dBm=sort_monte_carlo_pr_dBm-off_axis_loss;

                if any(isnan(sort_temp_mc_dBm))  %%%%%%%%Check
                    %disp_progress(app,strcat('ERROR PAUSE: Inside Agg Check Rev1: Line 158: NaN Error: temp_mc_dBm'))
                    pause;
                end

                %%%%%%Convert to Watts, Sum, and Find Aggregate
                %%%pow2db(0.1*1000)=20, 0.1 Watts = 20dBm
                %%%db2pow(20)/1000=0.1, 20dBm = 0.1 Watts
                binary_sort_mc_watts=db2pow(sort_temp_mc_dBm)/1000; %%%%%%

                if any(isnan(binary_sort_mc_watts))
                    disp_progress(app,strcat('ERROR PAUSE: Inside Agg Check Rev1: Line 168: NaN Error: temp_mc_watts'))
                    pause;
                end

                mc_agg_dbm=pow2db(sum(binary_sort_mc_watts,"omitnan")*1000);
                azimuth_agg_dBm(azimuth_idx)=mc_agg_dbm;
            end
            array_agg_check_mc_dBm(mc_iter,:)=azimuth_agg_dBm; %%%%%%%%%%%max across all azimuths for a single MC iteration
        end

        size(array_agg_check_mc_dBm)
        array_agg_check=prctile(array_agg_check_mc_dBm,mc_percentile);

% % %         figure;
% % %         hold on;
% % %         plot(array_agg_check_mc_dBm')
% % %         plot(array_agg_check,'-b','LineWidth',3)
% % %         grid on;
% % %         pause;


        retry_save=1;
        while(retry_save==1)
            try
                save(agg_check_file_name,'array_agg_check')
                retry_save=0;
            catch
                retry_save=1;
                pause(1)
            end
        end

    end
    toc;
end
end