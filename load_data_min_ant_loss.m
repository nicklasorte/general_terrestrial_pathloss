function [min_ant_loss]=load_data_min_ant_loss(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: min_ant_loss . . . '))

       load(strcat(data_label1,'_min_ant_loss.mat'),'min_ant_loss')
        temp_data=min_ant_loss;
        clear min_ant_loss;
        min_ant_loss=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end