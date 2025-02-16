function [array_full_pl_data,full_prop_mode_data]=load_full_pathloss_info_multi_rel_rev3(app,data_label1,string_prop_model,grid_spacing,tf_recalculate,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut,reliability)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function
filename_array_full_pl_data=strcat(data_label1,'_array_full_pl_data_',string_prop_model,'_',num2str(grid_spacing),'km.mat');
[var_exist_array_full_pl_data]=persistent_var_exist_with_corruption(app,filename_array_full_pl_data);

filename_full_prop_mode_data=strcat(data_label1,'_full_prop_mode_data_',string_prop_model,'_',num2str(grid_spacing),'km.mat');
[var_exist_full_prop_mode_data]=persistent_var_exist_with_corruption(app,filename_full_prop_mode_data);

if tf_recalculate==1
    var_exist_full_prop_mode_data=0;
end

if var_exist_full_prop_mode_data==2 && var_exist_array_full_pl_data==2
    retry_load=1;
    while(retry_load==1)
        try
            load(filename_array_full_pl_data,'array_full_pl_data')
            load(filename_full_prop_mode_data,'full_prop_mode_data')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    pause(0.1)
else
    [num_pts,~]=size(base_protection_pts)
    [num_grid_pts,~]=size(sim_array_list_bs)
    full_array_prop_mode=NaN(num_grid_pts,num_pts);
    num_rels=length(reliability)
    if num_rels>1 && matches(string_prop_model,'ITM')
        array_full_pl_data=NaN(num_grid_pts,num_pts,num_rels);
    else
        array_full_pl_data=NaN(num_grid_pts,num_pts);
    end

    full_prop_mode_data=NaN(num_grid_pts,num_pts);
    for point_idx=1:1:num_pts
        %%%%%%%%%'Load all the point pathloss calculations'
        %%%%%%Persistent Load
        file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
     
        retry_load=1;
        while(retry_load==1)
            [var_exist_pathloss]=persistent_var_exist_with_corruption(app,file_name_pathloss);
            if var_exist_pathloss==2
                try
                    load(file_name_pathloss,'pathloss')
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(1)
                end
            else
                disp_progress(app,strcat('Part2: No pathloss: Need to Calculate Pathloss  . . .'))
                pause(1)
            end
        end

        file_name_prop_mode=strcat(string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
        retry_load=1;
        while(retry_load==1)
            [var_exist_prop_mode]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
            if var_exist_prop_mode==2
                try
                    load(file_name_prop_mode,'prop_mode')
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(1)
                end
            else
                disp_progress(app,strcat('Part2: No prop_mode: Need to Calculate prop_mode  . . .'))
                pause(1)
            end
        end


        %%%%%%%%%%Clean up the prop_mode
        if strcmp(string_prop_model,'TIREM')
            num_cells=length(prop_mode);
            cell_prop_mode=cell(num_cells,1);
            array_rx_angle=NaN(num_cells,1);
            array_tx_angle=NaN(num_cells,1);

            for prop_idx=1:1:num_cells
                temp_structure=prop_mode{prop_idx};
                cell_prop_mode{prop_idx}=temp_structure.PropagationMode;
                array_tx_angle(prop_idx)=rad2deg(temp_structure.TransmitterTroposcatterAngle);
                array_rx_angle(prop_idx)=rad2deg(temp_structure.ReceiverTroposcatterAngle);
            end

            los_idx=find(contains(cell_prop_mode,'LOS'));
            diff_idx=find(contains(cell_prop_mode,'DIF'));
            tropo_idx=find(contains(cell_prop_mode,'TRO'));
            horzcat(min(array_rx_angle),max(array_rx_angle))
        end


        if strcmp(string_prop_model,'ITM')
            los_idx=find(prop_mode==0);
            dif1_idx=find(prop_mode==4);
            dif2_idx=find(prop_mode==5);
            dif3_idx=find(prop_mode==8);
            dif4_idx=find(prop_mode==9);
            diff_idx=unique(vertcat(dif1_idx,dif2_idx,dif3_idx,dif4_idx));
            trop1_idx=find(prop_mode==6);
            trop2_idx=find(prop_mode==10);
            tropo_idx=unique(vertcat(trop1_idx,trop2_idx));

            array_rx_angle=NaN(num_grid_pts,1);
        end

        if length(prop_mode)~=(length(los_idx)+length(diff_idx)+length(tropo_idx))
            'Error: Check prop_mode lengths'
            pause;
        end

        %%%%%%%%Now change to
        % % %  Mode of propagation
        % % % 1 = Line of Sight
        % % % 2 = Diffraction
        % % % 3 = Troposcatter

        array_prop_mode=NaN(size(prop_mode));
        array_prop_mode(los_idx)=1;
        array_prop_mode(diff_idx)=2;
        array_prop_mode(tropo_idx)=3;

        full_array_prop_mode(:,point_idx)=array_prop_mode;

        % if strcmp(string_prop_model,'TIREM')
        %full_rx_angle_data(:,point_idx)=array_rx_angle;
        %full_tx_angle_data(:,point_idx)=array_tx_angle;
        %end

        if tf_tropo_cut==1
            %%%%%% 'If it is tropo, we ignore the pathloss value'
            pathloss(tropo_idx,:)=NaN(1);
        end


        if num_rels>1 && matches(string_prop_model,'ITM')
            for rel_idx=1:1:num_rels
                array_full_pl_data(:,point_idx,rel_idx)=pathloss(:,rel_idx);
            end
        else
            array_full_pl_data(:,point_idx)=pathloss;
        end

        full_prop_mode_data(:,point_idx)=array_prop_mode;

        % % %                        %%%%%%%%%Find the Minimum Path Loss for each grid point and reliability (Doing this later)
        % % %                        if point_idx==1
        % % %                            min_full_pl_data=pathloss;
        % % %                            min_full_prop_mode_data=array_prop_mode;
        % % %                        else
        % % %                            min_full_pl_data=min(min_full_pl_data,pathloss,"omitnan");
        % % %                            min_full_prop_mode_data=min(min_full_prop_mode_data,array_prop_mode);
        % % %                        end

    end

    % % % %                     size(min_full_pl_data)
    % % % %                     nan_pl_idx=find(isnan(min_full_pl_data(:,1)));
    % % % %                     size(nan_pl_idx)


    retry_save=1;
    while(retry_save==1)
        try
            save(filename_array_full_pl_data,'array_full_pl_data')
            save(filename_full_prop_mode_data,'full_prop_mode_data')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    pause(0.1)
end

size(array_full_pl_data)
end
