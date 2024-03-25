function single_line_dpa_edga_rev1(app,rev_folder,string_prop_model,tf_server_status,sim_number,folder_names,tf_recalculate,parallel_flag,workers)

server_status_rev2(app,tf_server_status)
retry_cd=1;
while(retry_cd==1)
    try
        cd(rev_folder)
        pause(0.1);
        retry_cd=0;
    catch
        retry_cd=1;
        pause(0.1)
    end
end

[reliability]=load_data_reliability(app);
[confidence]=load_data_confidence(app);
[FreqMHz]=load_data_FreqMHz(app);
[Tpol]=load_data_Tpol(app);
[mc_percentile]=load_data_mc_percentile(app);
[mc_size]=load_data_mc_size(app);
[sim_radius_km]=load_data_sim_radius_km(app);
%[array_bs_eirp_reductions]=load_data_array_bs_eirp_reductions(app);
[min_binaray_spacing]=load_data_min_binaray_spacing(app);
%[deployment_percentage]=load_data_deployment_percentage(app);
%[line_dist_km]=load_data_line_dist_km(app);
[norm_aas_zero_elevation_data]=load_data_norm_aas_zero_elevation_data(app);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"wrapper" function is the binary search per line



%%%%%%%%%%%%%'If you get an error here, move the Tirem dlls to here'
[tf_tirem_error]=check_tirem_rev1(app,string_prop_model)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_binary_line_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_binary_line_status')
location_table=table([1:1:length(folder_names)]',folder_names)

%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
if tf_recalculate==1
    cell_status(:,2)=num2cell(0);
end
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status

if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);

    %%%%%%%%Pick a random folder and go to the folder to do the sim
    %%%disp_progress(app,strcat('Starting the Sims (Path Loss Calculation). . .',string_prop_model))
    disp_progress(app,strcat('Binary Search Line: Line 54'))
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.

    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end

    temp_folder_names(array_rand_folder_idx)
    disp_randfolder(app,num2str(array_rand_folder_idx'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Binary Search: ',num_folders);    %%%%%%% Create ParFor Waitbar

    for folder_idx=1:1:num_folders
        server_status_rev2(app,tf_server_status)
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.

        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
        if tf_recalculate==1
            cell_status(:,2)=num2cell(0);
        end
        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        if cell_status{temp_cell_idx,2}==0
            %%%%%%%%%%Calculate
            retry_cd=1;
            while(retry_cd==1)
                try
                    cd(rev_folder)
                    pause(0.1);
                    retry_cd=0;
                catch
                    retry_cd=1;
                    pause(0.1)
                end
            end

            retry_cd=1;
            while(retry_cd==1)
                try
                    sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
                    cd(sim_folder)
                    pause(0.1);
                    retry_cd=0;
                catch
                    retry_cd=1;
                    pause(0.1)
                end
            end

            disp_multifolder(app,sim_folder)
            data_label1=sim_folder


            %%%%%%Check for the tf_complete_ITM file
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
            [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
            if tf_recalculate==1
                var_exist=0;
            end
            if var_exist==2
                retry_cd=1;
                while(retry_cd==1)
                    try
                        cd(rev_folder)
                        pause(0.1);
                        retry_cd=0;
                    catch
                        retry_cd=1;
                        pause(0.1)
                    end
                end

                %%%%%%%%Update the Cell
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
            else
                %%%%%Persistent Load the other variables
                disp_progress(app,strcat('Binary Search Line: Line 138'))
                retry_load=1;
                while(retry_load==1)
                    try
                        disp_progress(app,strcat('Loading Sim Data . . . '))
                        [base_protection_pts]=load_data_base_protection_pts(app,data_label1);
                        [sim_array_list_bs]=load_data_sim_array_list_bs(app,data_label1);
                        [radar_threshold]=load_data_radar_threshold(app,data_label1);
                        [radar_beamwidth]=load_data_radar_beamwidth(app,data_label1);
                        [min_ant_loss]=load_data_min_ant_loss(app,data_label1);
                        [min_azimuth]=load_data_min_azimuth(app,data_label1);
                        [max_azimuth]=load_data_max_azimuth(app,data_label1);

                        % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end

                %%%%%%%%%Similar to the neighborhoods, pull the binary data.
                %%%%%%%%%%Binary Search
                [poolobj,cores]=start_parpool_poolsize_app(app,parallel_flag,workers);
                [num_ppts,~]=size(base_protection_pts);
                max_number_calc=ceil(log2(sim_radius_km))+2  %%%%For a simple binary search. We add 2 because we are doing the max and 0 also.
                %%%max_number_calc=sim_radius_km/min_binaray_spacing
                disp_progress(app,strcat('Binary Search Line: Line 165'))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [hWaitbar_binary,hWaitbarMsgQueue_binary]= ParForWaitbarCreateMH_time('Binary Search: ',max_number_calc);    %%%%%%% Create ParFor Waitbar, this one covers points and chunks

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                binary_dist_array=[1,2,4,8,16,32,64,128,256,512,1024];
                CBSD_label='BaseStation';
                [nn_idx]=nearestpoint_app(app,sim_radius_km,binary_dist_array,'next');
                bs_neighborhood=binary_dist_array(nn_idx);
                %%%%search_dist_array=horzcat(0:min_binaray_spacing:bs_neighborhood);
                search_dist_array=unique(horzcat(1,min_binaray_spacing:min_binaray_spacing:num_ppts));

                %%%We never end up using the search_dist_array: can add
                %%%this later


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start of Binary Search
                %%%%%%%Check for all_data_stats_binary, if none, initialize it.
                [all_data_stats_binary]=initialize_or_load_all_data_stats_binary_pre_label(app,data_label1,sim_number,base_protection_pts,CBSD_label);
                disp_progress(app,strcat('Binary Search Line: Line 185'))


                binary_marker=0;
                tf_search=1;
                while(tf_search==1)
                    %server_status_rev2(app,tf_server_status)
                    disp_progress(app,strcat('Binary Search Line: Line 193'))
                    binary_marker=binary_marker+1;
                    if binary_marker==1
                        single_search_dist=max(search_dist_array)
                        temp_data=cell2mat(all_data_stats_binary); %%%%%Check if that distance is in the all_data_stats_binary
                        if isempty(temp_data)==1 %%%%%%%%Because if this is the first time, it will be empty
                            temp_data_dist=NaN(1);
                        else
                            temp_data_dist=temp_data(:,1);
                        end
                    elseif binary_marker==2
                        single_search_dist=min(search_dist_array)
                        temp_data=cell2mat(all_data_stats_binary) %%%%Check if that distance is in the all_data_stats_binary
                        temp_data_dist=temp_data(:,1);
                    else
                        single_search_dist=next_single_search_dist
                        temp_data=cell2mat(all_data_stats_binary) %%%%%Check if that distance is in the all_data_stats_binary
                        temp_data_dist=temp_data(:,1);
                    end
                    disp_progress(app,strcat('Binary Search Line: Line 212'))


                    if any(temp_data_dist==single_search_dist)==1
                        %%%%%%%%Already calculated
                    else
                        %%%%%%%%Calculate
                        server_status_rev2(app,tf_server_status)
                        disp_progress(app,strcat('Binary Search Line: Line 219: Search Distance:',num2str(single_search_dist),'km'))
                        file_name_single_scrap_data=strcat(CBSD_label,'_',data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat'); %%%%%%First Check for an array file, named with the single_search_dist and has all the aggregate checks for each protection point.
                        [var_exist_single_scrap_data]=persistent_var_exist_with_corruption(app,file_name_single_scrap_data);

                        if var_exist_single_scrap_data==2
                            disp_progress(app,strcat('Binary Search Line: Line 224: Loading single_scrap_data:',num2str(single_search_dist),'km'))
                            retry_load=1;
                            while(retry_load==1)
                                try
                                    load(file_name_single_scrap_data,'single_scrap_data')
                                    retry_load=0;
                                catch
                                    retry_load=1;
                                    pause(1)
                                end
                            end
                        else %%%%if var_exist_single_scrap_data==0 %%%%%%%%Calculate Path loss, Aggregate Check
                            server_status_rev2(app,tf_server_status)
                            disp_progress(app,strcat('Binary Search Line: Line 237: Calculating Aggregate:',num2str(single_search_dist),'km'))
                            [array_agg_check]=agg_check_single_point_rev1(app,data_label1,string_prop_model,mc_percentile,reliability,sim_number,mc_size,single_search_dist,parallel_flag,workers,sim_array_list_bs,base_protection_pts,confidence,FreqMHz,Tpol,norm_aas_zero_elevation_data,radar_beamwidth,min_ant_loss,min_azimuth,max_azimuth);

                            single_scrap_data=NaN(1,2); %%%%Aggregate, Move List Size
                            single_scrap_data(1,1)=max(array_agg_check); %%%%%%Aggregate
                            single_scrap_data(1,2)=0; %%%%%Length of Move List

                            disp_progress(app,strcat('Binary Search Line: Line 244: Saving single_scrap_data :',num2str(single_search_dist),'km'))
                            retry_save=1;
                            while(retry_save==1)
                                try
                                    save(file_name_single_scrap_data,'single_scrap_data')
                                    retry_save=0;
                                catch
                                    retry_save=1;
                                    pause(1)
                                end
                            end
                        end
                        %server_status_rev2(app,tf_server_status)
                        disp_progress(app,strcat('Binary Search Line: Line 257: Putting single_scrap_data into the array :',num2str(single_search_dist),'km'))
                        single_scrap_data

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'Put it into the data array'
                        %%%%%%%%Distribute single_scrap_data to all_data_stats_binary
                        [all_data_stats_binary]=initialize_or_load_all_data_stats_binary_pre_label(app,data_label1,sim_number,base_protection_pts,CBSD_label);

                        %%%%Distance, Aggregate, Move List Size

                        temp_data=all_data_stats_binary{single_search_dist};
                        new_temp_data=vertcat(temp_data,horzcat(single_search_dist,single_scrap_data));
                        [uni_dist,uni_idx]=unique(new_temp_data(:,1));
                        uni_new_temp_data=new_temp_data(uni_idx,:);

                        % % % %                                     all_data_stats_binary=cell(x22,1); %%%%Leave the Cell empty
                        %%%%Distance, Aggregate, Move List Size

                        %%%%Sort the Data
                        [check_sort,sort_idx]=sort(uni_new_temp_data(:,1)); %%%%%%Sorting by Distance just in case
                        all_data_stats_binary{single_search_dist}=uni_new_temp_data(sort_idx,:);

                        %%%%%Save the Cell
                        pre_label=CBSD_label;
                        file_name_cell=strcat(pre_label,'_',data_label1,'_',num2str(sim_number),'_all_data_stats_binary.mat');
                        retry_save=1;
                        while(retry_save==1)
                            try
                                save(file_name_cell,'all_data_stats_binary')
                                retry_save=0;
                            catch
                                retry_save=1;
                                pause(0.1)
                            end
                        end
                    end
                    server_status_rev2(app,tf_server_status)

                    disp_progress(app,strcat('Binary Search Line: Line 294: Trying to Find the Next Distance to calculate :',num2str(single_search_dist),'km'))
                    %%%%%%%%%%%%%%%%Reload and plots
                    [all_data_stats_binary]=initialize_or_load_all_data_stats_binary_pre_label(app,data_label1,sim_number,base_protection_pts,CBSD_label);

                    if binary_marker>1
                        temp_binary_data=cell2mat(all_data_stats_binary);
                        [next_single_search_dist]=binary_search_next_dist_rev1(app,radar_threshold,temp_binary_data);

                        if ~isnan(next_single_search_dist)==1
                            tf_search=1; %%%%<--Flag for while loop
                        else
                            tf_search=0;
                        end
                    end
                    hWaitbarMsgQueue_binary.send(0);
                end  %%%%%%%End of while loop
                delete(hWaitbarMsgQueue_binary);
                close(hWaitbar_binary);


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%Save
                retry_save=1;
                while(retry_save==1)
                    try
                        comp_list=NaN(1);
                        save(complete_filename,'comp_list')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end

                retry_cd=1;
                while(retry_cd==1)
                    try
                        cd(rev_folder)
                        pause(0.1);
                        retry_cd=0;
                    catch
                        retry_cd=1;
                        pause(0.1)
                    end
                end
                disp_progress(app,strcat('Binary Search Line: Line 338: Updating Cell Status'))
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end
disp_progress(app,strcat('Binary Search Line: Line ##: Ending Calculation'))
server_status_rev2(app,tf_server_status)

end