function [base_protection_pts]=load_data_base_protection_pts(app,data_label1)



retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: base_protection_pts . . . '))
        
          load(strcat(data_label1,'_base_protection_pts.mat'),'base_protection_pts')
        temp_data=base_protection_pts;
        clear base_protection_pts;
        base_protection_pts=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end