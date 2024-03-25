function [min_azimuth]=load_data_min_azimuth(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: min_azimuth . . . '))

                        load(strcat(data_label1,'_min_azimuth.mat'),'min_azimuth')
        temp_data=min_azimuth;
        clear min_azimuth;
        min_azimuth=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end