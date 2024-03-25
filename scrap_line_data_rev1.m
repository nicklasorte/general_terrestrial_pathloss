function scrap_line_data_rev1(app,rev_folder,folder_names,sim_number)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Findpoint idx and pull in the lat/lon for that point.

num_folders=length(folder_names);
cell_line_pts=cell(num_folders,3);  %%%%%%%1) Name, 2)Distance km, 3)Lat/lon
cell_line_pts(:,1)=folder_names;
for folder_idx=1:1:num_folders
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

    sim_folder=folder_names{folder_idx};
    retry_cd=1;
    while(retry_cd==1)
        try
            cd(sim_folder)
            pause(0.1);
            retry_cd=0;
        catch
            retry_cd=1;
            pause(0.1)
        end
    end

    data_label1=sim_folder
    disp_progress(app,strcat('Scrapping data: Line ##:',data_label1))


    %%%%%Persistent Load the other variables
    retry_load=1;
    while(retry_load==1)
        try
            disp_progress(app,strcat('Loading Sim Data . . . '))
            [base_protection_pts]=load_data_base_protection_pts(app,data_label1);
            [radar_threshold]=load_data_radar_threshold(app,data_label1);
            retry_load=0;
        catch
            retry_load=1;
            pause(0.1)
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load Data
    CBSD_label='BaseStation';
    [all_data_stats_binary]=initialize_or_load_all_data_stats_binary_pre_label(app,data_label1,sim_number,base_protection_pts,CBSD_label);


    temp_binary_data=cell2mat(all_data_stats_binary);
    lo_km=0;  %%%%%%%%Which is really 1.
    hi_km=temp_binary_data(end,1);

    if hi_km-lo_km<=1
        mid_km=hi_km; %%%No more search
    else
        tf_binary_search=1;
        while(tf_binary_search==1) %%%Binary Search
            mid_km=ceil((hi_km+lo_km)/2);

            %%%%%See if the mid_km has data
            mid_row_idx=find(temp_binary_data(:,1)==mid_km);

            if isempty(mid_row_idx)
                'Error: Need more data'
                pause;
            elseif mid_km==hi_km
                tf_binary_search=0;
            else
                if temp_binary_data(mid_row_idx,2)<radar_threshold
                    hi_km=mid_km;
                else
                    lo_km=mid_km;
                end
            end
        end
    end

    cell_line_pts{folder_idx,2}=mid_km;
    cell_line_pts{folder_idx,3}=base_protection_pts(mid_km,[1,2]);

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
end



retry_save=1;
while(retry_save==1)
    try
        save(strcat('cell_line_pts_',num2str(sim_number),'.mat'),'cell_line_pts')

        %%%%%%%'Write an excel file'
        table_line_dist=cell2table(cell_line_pts(:,[1,2]));
        table_line_dist.Properties.VariableNames={'Line_Name' 'Distance_km'}
        writetable(table_line_dist,strcat('DPA_Edge_',num2str(sim_number),'.xlsx'));

        pause(0.1);
        retry_save=0;
    catch
        retry_save=1;
        pause(0.1)
    end
end


end