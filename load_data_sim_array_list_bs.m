function [sim_array_list_bs]=load_data_sim_array_list_bs(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: sim_array_list_bs . . . '))
        
          load(strcat(data_label1,'_sim_array_list_bs.mat'),'sim_array_list_bs')
        temp_data=sim_array_list_bs;
        clear sim_array_list_bs;
        sim_array_list_bs=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end

      % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation
