function [tf_clutter]=load_data_tf_clutter(app)


retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: tf_clutter . . . '))
        
        load('tf_clutter.mat','tf_clutter')
        temp_data=tf_clutter;
        clear tf_clutter;
        tf_clutter=temp_data;
        clear temp_data;
        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end