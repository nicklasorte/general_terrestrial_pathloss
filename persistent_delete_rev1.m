function persistent_delete_rev1(app,filename)

disp_progress(app,strcat('Pathloss Clean up: Line3: Inside persistent_delete_rev1:',filename))   
%%%%%%Check first if it exists.
[var_exist3]=simple_persistent_var_exist(app,filename);
if var_exist3==2
    tf_delete=1;
else%%%%%%If it doesn't exist, we don't have to delete.
    tf_delete=0;
end
disp_progress(app,strcat('Pathloss Clean up: Line11: Inside persistent_delete_rev1:',filename))
while(tf_delete==1)
    disp_progress(app,strcat('Pathloss Clean up: Line13: Inside persistent_delete_rev1:',filename))   
    [var_exist3]=simple_persistent_var_exist(app,filename);
    if var_exist3==2
        %%%%Need to try and catch
        try
            disp_progress(app,strcat('Pathloss Clean up: Line18: Inside persistent_delete_rev1:',filename)) 
            delete(filename)
            tf_delete=0;
        catch
            disp_progress(app,strcat('Pathloss Clean up: Line22: Inside persistent_delete_rev1:',filename)) 
            tf_delete=1;
            pause(0.1);
        end
    else  %%%%%%If it doesn't exist, we don't have to delete.
        disp_progress(app,strcat('Pathloss Clean up: Line27: Inside persistent_delete_rev1:',filename)) 
        tf_delete=0;
    end
end
disp_progress(app,strcat('Pathloss Clean up: Line31: Inside persistent_delete_rev1:',filename))   
%%%%%%%This seems to be the last message

end