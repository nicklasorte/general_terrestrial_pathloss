function part1_calc_pathloss_point_clean_rev9(app,rev_folder,folder_names,parallel_flag,sim_number,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,tf_recalc_pathloss,tf_server_status)



% % % % % % % % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Randomize the chunk
% % % % % % % % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sequence and randomize the
% % % % % % % % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%protection point
server_status_rev2(app,tf_server_status)


%%%%%%%%%%%%%'If you get an error here, move the Tirem dlls to here'
[tf_tirem_error]=check_tirem_rev1(app,string_prop_model)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function: 
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_dll_status.mat')  
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_dll_status')
location_table=table([1:1:length(folder_names)]',folder_names)

%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
if tf_recalc_pathloss==1
    cell_status(:,2)=num2cell(0);
end
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status


if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);
    
    %%%%%%%%Pick a random folder and go to the folder to do the sim
    %%%disp_progress(app,strcat('Starting the Sims (Path Loss Calculation). . .',string_prop_model))
    disp_progress(app,strcat('Part1 Calc Pathloss: Line 39'))    
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.
   
    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end

     temp_folder_names(array_rand_folder_idx)
     disp_randfolder(app,num2str(array_rand_folder_idx'))
     %disp_randfolder(app,temp_folder_names(array_rand_folder_idx))
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Pathloss: ',num_folders);    %%%%%%% Create ParFor Waitbar
        
    for folder_idx=1:1:num_folders
        %%%server_status_rev1(app)
        server_status_rev2(app,tf_server_status)
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.
        
        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
        if tf_recalc_pathloss==1
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
            data_label1=sim_folder;
            
            %%%%%%Check for the tf_complete_ITM file
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
            [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
            if tf_recalc_pathloss==1
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

                %%%%%%%%Calculate Path Loss
                %%%%%%%%%%%%%%%%CBSD Neighborhood Search Parameters
                %%%%%Persistent Load the other variables
                disp_progress(app,strcat('Part1 Calc Pathloss: Line 120, Loading Sim Data  . . .'))    
                retry_load=1;
                while(retry_load==1)
                    try
                        disp_progress(app,strcat('Loading Sim Data . . . '))
                        load(strcat(data_label1,'_base_protection_pts.mat'),'base_protection_pts')
                        temp_data=base_protection_pts;
                        clear base_protection_pts;
                        base_protection_pts=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_sim_array_list_bs.mat'),'sim_array_list_bs')
                        temp_data=sim_array_list_bs;
                        clear sim_array_list_bs;
                        sim_array_list_bs=temp_data;
                        clear temp_data;
                           % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the pathloss

                % %%%%%%%%%%%%%%Calculate Path Loss (Parallel Chunks)
                   %%%%%%Parchunk even if we have no parpool
                [num_pts,~]=size(base_protection_pts);
                [poolobj,cores]=start_parpool_poolsize_app(app,parallel_flag,workers);
                disp_progress(app,strcat('Part1 Calc Pathloss: Line 160'))     
                %%%%%server_status_rev1(app)
                server_status_rev2(app,tf_server_status)

                [num_bs,~]=size(sim_array_list_bs);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we define the num_chunks
                dyn_chunks=ceil(num_bs/1000)
                num_chunks=max([24,dyn_chunks])

                chuck_size=floor(num_bs/num_chunks);
                cell_sim_chuck_idx=cell(num_chunks,1);

                for sub_idx=1:1:num_chunks  %%%%%%Define the sim idxs
                    if sub_idx==num_chunks
                        start_idx=(sub_idx-1).*chuck_size+1;
                        stop_idx=num_bs;
                        temp_sim_idx=start_idx:1:stop_idx;
                    else
                        start_idx=(sub_idx-1).*chuck_size+1;
                        stop_idx=sub_idx.*chuck_size;
                        temp_sim_idx=start_idx:1:stop_idx;
                    end
                    cell_sim_chuck_idx{sub_idx}=temp_sim_idx;
                end
                %%%%%Check
                missing_idx=find(diff(horzcat(cell_sim_chuck_idx{:}))>1);
                num_idx=length(unique(horzcat(cell_sim_chuck_idx{:})));
                if ~isempty(missing_idx) || num_idx~=num_bs
                    'Error:Check Chunk IDX'
                    pause;
                end
                 disp_progress(app,strcat('Part1 Calc Pathloss: Line 187'))  


                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Randomize the Point Order for
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%when we have more than 1
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%server running
                 if tf_ml_toolbox==1
                     array_rand_point_idx=randsample(num_pts,num_pts,false);
                 else
                     array_rand_point_idx=randperm(num_pts);
                 end
                 %%%%array_rand_point_idx=1:1:num_pts

                 if tf_ml_toolbox==1
                     array_rand_chunk_idx=randsample(num_chunks,num_chunks,false);
                 else
                     array_rand_chunk_idx=randperm(num_chunks);
                 end
                 array_rand_chunk_idx


                [hWaitbar_pathloss,hWaitbarMsgQueue_pathloss]= ParForWaitbarCreateMH_time('Path Loss: ',num_pts*num_chunks);    %%%%%%% Create ParFor Waitbar, this one covers points and chunks
                for rand_pt_idx=1:1:num_pts
                    point_idx=array_rand_point_idx(rand_pt_idx)

                    server_status_rev2(app,tf_server_status)
                    disp_progress(app,strcat('Part1 Calc Pathloss: Line 207, point_idx:',num2str(point_idx)))   
                    file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                    file_name_prop_mode=strcat(string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');

                    %%%%Check if it's there
                    [var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
                    [var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
                    if tf_recalc_pathloss==1
                        var_exist1=0;
                    end

                    disp_progress(app,strcat('Part1 Calc Pathloss:: Line 218: Point Idx:Var1-Var2:',num2str(point_idx),'_',num2str(var_exist1),'_',num2str(var_exist2)))

                    if var_exist1==0 || var_exist2==0
                        if parallel_flag==1
                            parfor chunk_idx=1:num_chunks  %%%%%%%%%Parfor
                               %%%%%%%%%%%%%%%Need to add a check for the
                               %%%%%%%%%%%%%%%file_name_pathloss and
                               %%%%%%%%%%%%%%%file_name_prop_mode inside
                               %%%%%%%%%%%%%%%the parfor_rand_parchunk_PropModel_angels_rev5
                                %%parfor_rand_parchunk_PropModel_angels_rev5(app,cell_sim_chuck_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model,array_rand_chunk_idx,chunk_idx);
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
                                disp_progress(app,strcat('Part1 Calc Pathloss:: Line 2236: point_idx:sub_point_idx:',num2str(point_idx),'_',num2str(sub_point_idx)))
                                %%%%[cell_pathloss{sub_point_idx},cell_prop_mode{sub_point_idx}]=parfor_parchunk_PropModel_angels_rev4(app,cell_sim_chuck_idx,sub_point_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model);
                                %%%%%%%%%%%%%%%%%%%[cell_pathloss{sub_point_idx},cell_prop_mode{sub_point_idx}]=parfor_rand_parchunk_PropModel_angels_rev5(app,cell_sim_chuck_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model,array_rand_chunk_idx,chunk_idx);
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

                        if num_pl~=num_bs
                            horzcat(num_pl,num_bs)
                            disp_progress(app,strcat('Part1 Calc Pathloss: Line 251: Pause Error: Number of Pathloss/Base Station:',num2str(point_idx)))
                            pause;
                        end
                        %%%%server_status_rev1(app)
                        server_status_rev2(app,tf_server_status)

                        %%%%%%%%%ITM prop mode decoder ring
                        %%%% 0 LOS, 4 Single Horizon, 5 Difraction Double Horizon, 8 Double Horizon, 9 Difraction Single Horizon, 6 Troposcatter Single Horizon, 10 Troposcatter Double Horizon, 333 Error

                        %%%%%Need to convert the ITM prop mode number to a string (later on).

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check to see if it exists before saving it.
                        [var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
                        [var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
                        if var_exist1==0 || var_exist2==0
                            if any(isnan(pathloss))
                                disp_progress(app,strcat('Part1 Calc Pathloss: Line 284: Pause Error: Pathloss is NaN:',num2str(point_idx)))
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
                                disp_progress(app,strcat('Path Loss Clean Up: Line 417: While Loop Waiting: The files dont exist and we should not delete the subchunks. Wait for other servers to catch up.'))
                                tf_file_check_loop=1;
                                pause(10)
                            end
                        end


                        if var_exist1==2 && var_exist2==2
                            %%%%%%%%%Loop for deleting
                            for sub_point_idx=1:num_chunks
                                disp_progress(app,strcat('Propagation: Pathloss Clean up: Line 427: point_idx:',num2str(point_idx),':',num2str(sub_point_idx)))
                                %%%%'The error is occuring after this point. Add additional disp points'

                                file_name_pathloss_sub_delete=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                                persistent_delete_rev1(app,file_name_pathloss_sub_delete)

                                file_name_propmode_sub_delete=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                                persistent_delete_rev1(app,file_name_propmode_sub_delete)
                            end
                        else
                            disp_progress(app,strcat('ERROR PAUSE: Pathloss Clean up: Line 204: point_idx:',num2str(point_idx),': While Loop did not work. The files dont exist and we should not delete the subchunks.'))
                            pause;
                        end


                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of clean up
                    else
                        %%%%%Need to decrement the waitbar
                        for i=1:num_chunks
                            hWaitbarMsgQueue_pathloss.send(0);
                        end
                    end
                end

                delete(hWaitbarMsgQueue_pathloss);
                close(hWaitbar_pathloss);
                %%%%server_status_rev1(app)
                server_status_rev2(app,tf_server_status)

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
                disp_progress(app,strcat('Part1 Calc Pathloss: Line 316: Updating Cell Status'))
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                %%%%server_status_rev1(app)
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end
disp_progress(app,strcat('Part1 Calc Pathloss: Line 319: Ending Pathloss Calculation'))
%%%%server_status_rev1(app)
server_status_rev2(app,tf_server_status)


% % % tf_reclean=0
% % % propagation_clean_up_server_rev3(app,rev_folder,folder_names,parallel_flag,sim_number,workers,string_prop_model,num_chunks,tf_server_status,tf_reclean)
tf_reclean=0
propagation_clean_up_server_dyn_chunks_rev4(app,rev_folder,folder_names,parallel_flag,sim_number,workers,string_prop_model,tf_server_status,tf_reclean)

