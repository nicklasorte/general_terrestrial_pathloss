function [line_dist_km]=load_data_line_dist_km(app)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: line_dist_km . . . '))
        
        load('line_dist_km.mat','line_dist_km')
        temp_data=line_dist_km;
        clear line_dist_km;
        line_dist_km=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end