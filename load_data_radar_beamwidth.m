function [radar_beamwidth]=load_data_radar_beamwidth(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: radar_beamwidth . . . '))


        load(strcat(data_label1,'_radar_beamwidth.mat'),'radar_beamwidth')
        temp_data=radar_beamwidth;
        clear radar_beamwidth;
        radar_beamwidth=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end