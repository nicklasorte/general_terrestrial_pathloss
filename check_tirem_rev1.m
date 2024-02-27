function [tf_tirem_error]=check_tirem_rev1(app,string_prop_model)


if strcmp(string_prop_model,'TIREM')
    try
        %%%%%%%%%%%%%'If you get an error here, move the Tirem dlls to here'
        tiremSetup('C:\USGS\TIREM5')  %%%%%%%%%This to the folder of the TIREM dlls
        tf_tirem_error=0;
    catch
        tf_tirem_error=1;
    end
else
    tf_tirem_error=0;
end

if tf_tirem_error==1
    disp_progress(app,strcat('TIREM Setup Error. . .'))
    pause;
end
end