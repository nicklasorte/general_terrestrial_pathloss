function [pathloss,prop_mode,tf_stop_subchunk]=parfor_rand_parchunk_PropModel_precheck_order_rev9(app,cell_sim_chuck_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model,array_rand_chunk_idx,chunk_idx,file_name_pathloss,file_name_prop_mode)



sub_point_idx=array_rand_chunk_idx(chunk_idx);
if parallel_flag==0
    disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 7: sub_point_idx:',num2str(sub_point_idx))) 
end

%%%%Check if the big file is there before
[var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
[var_exist2]=persistent_var_exist_with_corruption(app,file_name_prop_mode);
if parallel_flag==0
    disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 14: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2)))
end

if var_exist1==2 && var_exist2==2
    %'It does exist and we  don't need to load the sub-chunk
    if parallel_flag==0
        disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 22: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2)))
    end
    tf_stop_subchunk=1;
    prop_mode=NaN(1,1);
    pathloss=NaN(1,1);
else
    %%%%%%%%%%%%%%%%%%%%The large file doesn't exist, we need to check for the chunk.
    if parallel_flag==0
        disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 28: sub_point_idx:',num2str(sub_point_idx)))  %%%%%Last Update Here before Pause: Line 6-Line 19: Probably->persistent_var_exist_with_corruption
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Parchunk ParWrapper
    sub_idx=cell_sim_chuck_idx{sub_point_idx};
    sub_sim_array_list_bs=sim_array_list_bs(sub_idx,:);
    sim_pt=base_protection_pts(point_idx,:);
    if parallel_flag==0
        disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 35: sub_point_idx:',num2str(sub_point_idx)))
    end %%%%%%%%%%%This was the last check point before a stop.

    %%%%%%Check/Calculate path loss
    file_name_pathloss_chunk=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
    file_name_propmode_chunk=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
    [var_exist1_chunk]=persistent_var_exist_with_corruption(app,file_name_pathloss_chunk);
    [var_exist2_chunk]=persistent_var_exist_with_corruption(app,file_name_propmode_chunk);
    if parallel_flag==0
        disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 44: var_exist1_chunk:',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
    end

    tf_stop_subchunk=0; %%%%%%%Large file doesn't exist, keep going.
    %%%%%%%%%%%%%%%%%%%%%%%Large file does not exist, see if we need to calculate the sub-chunk
    if var_exist1_chunk==2 && var_exist2_chunk==2 && parallel_flag==0 %%%%%%%%%%%%%We should only load in the non-parllel
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 51: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
        end %%%%%%%%This is where we are stopping. Error before the load. 0-0-2-2, Another Stop here before the load.
        retry_load=1;
        while(retry_load==1) %%%%%%
            try
                load(file_name_pathloss_chunk,'pathloss')
                load(file_name_propmode_chunk,'prop_mode')
                retry_load=0;
            catch
                retry_load=1;
                pause(1)  %%%%%%%%%%%Need to catch the error here and display it.
            end
        end
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 65: Successful Load: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
        end 
    elseif var_exist1_chunk==2 && var_exist2_chunk==2 && parallel_flag==1  %%%%%Parallel, just need a placeholder: No loading
        prop_mode=NaN(1,1);
        pathloss=NaN(1,1);
    else
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 70: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
        end
        %%%%%%%%The sub-chunk doesn't exist and we need to calculate it
        if strcmp(string_prop_model,'TIREM')
            [pathloss,prop_mode]=TIREM5_mechanism_angles_rev4(app,sub_sim_array_list_bs,sim_pt,FreqMHz,parallel_flag);
        elseif  strcmp(string_prop_model,'ITM')
            [pathloss,prop_mode]=ITMP2P_mechanism_rev4_embed_height(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,FreqMHz,Tpol,parallel_flag);
        elseif strcmp(string_prop_model,'matlab_longley_rice')
            [pathloss,prop_mode]=matlab_longley_rice_angles_rev2(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,FreqMHz,parallel_flag);
        elseif strcmp(string_prop_model,'matlab_tirem')
            disp_progress(app,strcat('Need to remove radar height, as it in the sim_pts'))
            pause;
            [pathloss,prop_mode]=matlab_tirem_rev1(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,radar_height,FreqMHz,parallel_flag);
        elseif  strcmp(string_prop_model,'P2001')
            [pathloss,prop_mode]=P2001_mechanism_rev1(app,sub_sim_array_list_bs,sim_pt,reliability,FreqMHz,Tpol,parallel_flag);
        else
            disp_progress(app,strcat('Unknown Propagation Model'))
            pause;
        end
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 90: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
        end

        if parallel_flag==0
            disp_progress(app,strcat('Pathloss: Parfor Parchunk: Saving:',num2str(point_idx),'_',num2str(sub_point_idx)))
        end
        %%%%%%Persistent Save
        [var_exist3]=persistent_var_exist_with_corruption(app,file_name_pathloss_chunk);
        [var_exist4]=persistent_var_exist_with_corruption(app,file_name_propmode_chunk);
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 100: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk),'_',num2str(var_exist3),'_',num2str(var_exist4)))
        end
        if var_exist3==0 || var_exist4==0
            retry_save=1;
            while(retry_save==1)
                try
                    save(file_name_propmode_chunk,'prop_mode')
                    save(file_name_pathloss_chunk,'pathloss')
                    retry_save=0;
                catch
                    retry_save=1;
                    pause(1)
                end
            end
        end
        if parallel_flag==0
            disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 116: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk),'_',num2str(var_exist3),'_',num2str(var_exist4)))
        end
    end
    if parallel_flag==0
        disp_TextArea_PastText(app,strcat('parfor_rand_parchunk_PropModel_precheck_order_rev9: Line 120: var_exist1:',num2str(var_exist1),'_',num2str(var_exist2),'_',num2str(var_exist1_chunk),'_',num2str(var_exist2_chunk)))
    end
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Wrapper