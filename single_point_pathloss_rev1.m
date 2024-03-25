function [pathloss]=single_point_pathloss_rev1(app,string_prop_model,point_idx,sim_number,data_label1,parallel_flag,workers,sim_array_list_bs,base_protection_pts,reliability,confidence,FreqMHz,Tpol)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pathloss Function (Single Point)
'Calculate single point path loss'
file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
[var_exist_pathloss]=persistent_var_exist_with_corruption(app,file_name_pathloss);
if var_exist_pathloss==2
    retry_load=1;
    while(retry_load==1)
        try
            load(file_name_pathloss,'pathloss')
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
else
    'Calculate single point path loss'
    % %%%%%%%%%%%%%%Calculate Path Loss (Parallel Chunks)
    %%%%%%Parchunk even if we have no parpool
    [poolobj,cores]=start_parpool_poolsize_app(app,parallel_flag,workers);
    disp_progress(app,strcat('Single Point Pathloss: Line 23'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we define the num_chunks
    [num_chunks,cell_sim_chuck_idx,array_rand_chunk_idx]=rand_chunks_rev1(app,sim_array_list_bs);
    [hWaitbar_pathloss,hWaitbarMsgQueue_pathloss]= ParForWaitbarCreateMH_time('Path Loss: ',num_chunks);    %%%%%%% Create ParFor Waitbar, this one covers points and chunks

    disp_progress(app,strcat('Single Point Pathloss: Line 29'))
    %file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
    file_name_prop_mode=strcat(string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');

    %%%%Check if it's there
    [var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
    [var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
    disp_progress(app,strcat('Single Point Pathloss: Line 36: Point Idx:Var1-Var2:',num2str(point_idx),'_',num2str(var_exist1),'_',num2str(var_exist2)))

    if var_exist1==0 || var_exist2==0
        if parallel_flag==1
            parfor chunk_idx=1:num_chunks  %%%%%%%%%Parfor
                parfor_rand_parchunk_PropModel_precheck_rev6(app,cell_sim_chuck_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model,array_rand_chunk_idx,chunk_idx,file_name_pathloss,file_name_prop_mode);
                hWaitbarMsgQueue_pathloss.send(0);
            end
        end

        %%%%%%%%%Then Assemble with for loop
        cell_pathloss=cell(num_chunks,1);
        cell_prop_mode=cell(num_chunks,1);
        tf_stop_subchunk=0;
        for chunk_idx=1:num_chunks  %%%%%%%%%Parfor
            sub_point_idx=array_rand_chunk_idx(chunk_idx)
            horzcat(chunk_idx,sub_point_idx)

            if tf_stop_subchunk==0
                disp_progress(app,strcat('Single Point Pathloss: Line 55: point_idx:sub_point_idx:',num2str(point_idx),'_',num2str(sub_point_idx)))
                [cell_pathloss{sub_point_idx},cell_prop_mode{sub_point_idx},tf_stop_subchunk]=parfor_rand_parchunk_PropModel_precheck_rev6(app,cell_sim_chuck_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model,array_rand_chunk_idx,chunk_idx,file_name_pathloss,file_name_prop_mode);
            end
            tf_stop_subchunk
            %%%%Once the tf_stop_subchunk

            if parallel_flag==0
                %%%%%%%Decrement the waitbar
                hWaitbarMsgQueue_pathloss.send(0);
            end
        end

        prop_mode=vertcat(cell_prop_mode{:});
        pathloss=vertcat(cell_pathloss{:});
        [num_pl,~]=size(pathloss);

        [num_bs,~]=size(sim_array_list_bs);
        if num_pl~=num_bs
            horzcat(num_pl,num_bs)
            disp_progress(app,strcat('Single Point Pathloss: Line 73: Pause Error: Number of Pathloss/Base Station:',num2str(point_idx)))
            pause;
        end
        %%%server_status_rev2(app,tf_server_status)

       %%%%%%%%%ITM prop mode decoder ring
        %%%% 0 LOS, 4 Single Horizon, 5 Difraction Double Horizon, 8 Double Horizon, 9 Difraction Single Horizon, 6 Troposcatter Single Horizon, 10 Troposcatter Double Horizon, 333 Error

        %%%%%Need to convert the ITM prop mode number to a string (later on).

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check to see if it exists before saving it.
        [var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
        [var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
        if var_exist1==0 || var_exist2==0
            if any(isnan(pathloss))
                disp_progress(app,strcat('Single Point Pathloss: Line 89: Pause Error: Pathloss is NaN:',num2str(point_idx)))
                pause;
            end
            retry_save=1;
            while(retry_save==1)
                try
                    save(file_name_pathloss,'pathloss')
                    save(file_name_prop_mode,'prop_mode')
                    retry_save=0;
                catch
                    retry_save=1;
                    pause(1)
                end
            end
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'This is where we then clean up the single point'


        %%%%%%%%%%%%Double check that it is there.
        tf_file_check_loop=1;
        while(tf_file_check_loop==1)
            try
                [var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
                [var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
                pause(0.1);
            catch
                var_exist1=0;
                var_exist2=0;
                pause(0.1)
            end
            if var_exist1==2 && var_exist2==2
                tf_file_check_loop=0;
            else
                disp_progress(app,strcat('Single Point Pathloss: Line 126: Path Loss Clean Up: While Loop Waiting: The files dont exist and we should not delete the subchunks. Wait for other servers to catch up.'))
                tf_file_check_loop=1;
                pause(10)
            end
        end


        if var_exist1==2 && var_exist2==2
            %%%%%%%%%Loop for deleting
            for sub_point_idx=1:num_chunks
                disp_progress(app,strcat('Single Point Pathloss: Line 136: Pathloss Clean up: point_idx:',num2str(point_idx),':',num2str(sub_point_idx)))
                %%%%'The error is occuring after this point. Add additional disp points'

                file_name_pathloss_sub_delete=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                persistent_delete_rev1(app,file_name_pathloss_sub_delete)
                disp_progress(app,strcat('Single Point Pathloss: Line 139: Pathloss Clean up: point_idx:',num2str(point_idx),':',num2str(sub_point_idx)))

                file_name_propmode_sub_delete=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                persistent_delete_rev1(app,file_name_propmode_sub_delete)
                disp_progress(app,strcat('Single Point Pathloss: Line 143: Pathloss Clean up: point_idx:',num2str(point_idx),':',num2str(sub_point_idx)))
            end
        else
            disp_progress(app,strcat('ERROR PAUSE: Single Point Pathloss: Pathloss Clean up: Line 146: point_idx:',num2str(point_idx),': While Loop did not work. The files dont exist and we should not delete the subchunks.'))
            pause;
        end
        disp_progress(app,strcat('Single Point Pathloss: Line 149'))


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of clean up
    else
        %%%%%Need to decrement the waitbar
        for i=1:num_chunks
            hWaitbarMsgQueue_pathloss.send(0);
        end
    end

    delete(hWaitbarMsgQueue_pathloss);
    close(hWaitbar_pathloss);
    %server_status_rev2(app,tf_server_status)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of pathloss function

end