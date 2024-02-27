function [tf_calc_rx_angle]=load_data_tf_calc_rx_angle(app)


retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: tf_calc_rx_angle . . . '))

        load('tf_calc_rx_angle.mat','tf_calc_rx_angle')
        temp_data=tf_calc_rx_angle;
        clear tf_calc_rx_angle;
        tf_calc_rx_angle=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end


end