function [radar_threshold]=load_data_radar_threshold(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: radar_threshold . . . '))
        
                load(strcat(data_label1,'_radar_threshold.mat'),'radar_threshold')
        temp_data=radar_threshold;
        clear radar_threshold;
        radar_threshold=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end