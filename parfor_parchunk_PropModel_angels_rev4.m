function [pathloss,prop_mode]=parfor_parchunk_PropModel_angels_rev4(app,cell_sim_chuck_idx,sub_point_idx,sim_array_list_bs,base_protection_pts,sim_number,data_label1,reliability,confidence,FreqMHz,Tpol,parallel_flag,point_idx,string_prop_model)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Parchunk ParWrapper
sub_idx=cell_sim_chuck_idx{sub_point_idx};
sub_sim_array_list_bs=sim_array_list_bs(sub_idx,:);
sim_pt=base_protection_pts(point_idx,:);

%%%%%%Check/Calculate path loss
file_name_pathloss=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
file_name_propmode=strcat('sub_',num2str(sub_point_idx),'_',string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
[var_exist1]=persistent_var_exist_with_corruption(app,file_name_pathloss);
[var_exist2]=persistent_var_exist_with_corruption(app,file_name_propmode);
if var_exist1==0 || var_exist2==0
    if strcmp(string_prop_model,'TIREM')
        %%%%%%%[pathloss,prop_mode]=TIREM5_mechanism_rev3(app,sub_sim_array_list_bs,sim_pt,radar_height,FreqMHz,parallel_flag);
        [pathloss,prop_mode]=TIREM5_mechanism_angles_rev4(app,sub_sim_array_list_bs,sim_pt,FreqMHz,parallel_flag);
    elseif  strcmp(string_prop_model,'ITM')
        %%%%%%%%%%%%%[pathloss,prop_mode]=ITMP2P_mechanism_rev3(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);
        [pathloss,prop_mode]=ITMP2P_mechanism_rev4_embed_height(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,FreqMHz,Tpol,parallel_flag);
    elseif strcmp(string_prop_model,'matlab_longley_rice')
        %%%%%%%[pathloss,prop_mode]=matlab_longley_rice_rev1(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);
        [pathloss,prop_mode]=matlab_longley_rice_angles_rev2(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,FreqMHz,parallel_flag);
    elseif strcmp(string_prop_model,'matlab_tirem')
         'Need to remove radar height, as it in the sim_pts'
        pause;
         [pathloss,prop_mode]=matlab_tirem_rev1(app,sub_sim_array_list_bs,sim_pt,reliability,confidence,radar_height,FreqMHz,parallel_flag);
    elseif  strcmp(string_prop_model,'P2001')
        [pathloss,prop_mode]=P2001_mechanism_rev1(app,sub_sim_array_list_bs,sim_pt,reliability,FreqMHz,Tpol,parallel_flag);
    else
        'Unknown Propagation Model'
        pause;
    end

    if parallel_flag==0
        disp_progress(app,strcat('Pathloss: Parfor Parchunk: Saving:',num2str(point_idx),'_',num2str(sub_point_idx)))
    end
    %%%%%%Persistent Save
    [var_exist3]=persistent_var_exist_with_corruption(app,file_name_pathloss);
    [var_exist4]=persistent_var_exist_with_corruption(app,file_name_propmode);
    if var_exist3==0 || var_exist4==0
        retry_save=1;
        while(retry_save==1)
            try
               save(file_name_propmode,'prop_mode')
               save(file_name_pathloss,'pathloss')
                retry_save=0;
            catch
                retry_save=1;
                pause(1)
            end
        end
    end
elseif var_exist1==2 && var_exist2==2
     %%%%if parallel_flag==0 %%%%%%%%%%%%%We should only load in the non-parllel p
    retry_load=1;
    while(retry_load==1)
        try
            load(file_name_pathloss,'pathloss')
            load(file_name_propmode,'prop_mode')
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
     %%%%%end
else
    disp_progress(app,strcat('ERROR in Logic: Pathloss: Parfor Parchunk:Line 60: Point:',num2str(point_idx),'_Subpoint:',num2str(sub_point_idx),'_',num2str(var_exist1),'_',num2str(var_exist2)))
    pause;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Wrapper

end