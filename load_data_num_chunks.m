function [num_chunks]=load_data_num_chunks(app)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: num_chunks . . . '))
        load('num_chunks.mat','num_chunks')
        temp_data=num_chunks;
        clear num_chunks;
        num_chunks=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end