function [max_azimuth]=load_data_max_azimuth(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: max_azimuth . . . '))
    load(strcat(data_label1,'_max_azimuth.mat'),'max_azimuth')
        temp_data=max_azimuth;
        clear max_azimuth;
        max_azimuth=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end