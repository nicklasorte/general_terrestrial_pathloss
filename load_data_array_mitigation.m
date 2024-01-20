function [array_mitigation]=load_data_array_mitigation(app)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: array_mitigation . . . '))

        load('array_mitigation.mat','array_mitigation')
        temp_data=array_mitigation;
        clear array_mitigation;
        array_mitigation=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end


end