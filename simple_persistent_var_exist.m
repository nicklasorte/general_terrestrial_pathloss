function [var_exist]=simple_persistent_var_exist(app,file_name)
retry_exists=1;
while(retry_exists==1)
    try
        var_exist=exist(file_name,'file');
        retry_exists=0;
    catch
        retry_exists=1;
        pause(0.1)
    end
end
