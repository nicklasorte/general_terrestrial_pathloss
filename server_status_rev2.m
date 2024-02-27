function server_status_rev2(app,tf_server_status)

if tf_server_status==1
    if isdeployed==1  %%%%%%%%%Only doing this for the compiled app
        disp_progress(app,strcat('Updating Server Status: Line 4'))
        tic;
        %%%%%%%%%%%%%%First check for the current directory. --> sim_folder
        sim_folder=cd

        %%%%%%%%%%%%%%%%%%Go to the server folder
        retry_cd=1;
        while(retry_cd==1)
            try
                cd('Z:\MATLAB\Server_Status')
                pause(0.1);
                retry_cd=0;
            catch
                retry_cd=1;
                pause(0.1)
                disp_progress(app,strcat('Error in Server Status: Line 19: Cant go to directory --> Z:\MATLAB\Server_Status'))
            end
        end


        %%%%%%%Get the computer name
        disp_progress(app,strcat('Updating Server Status: Line 25'))
        computer_name=getenv('COMPUTERNAME');

        %%%%%%%%%%%%%%Save the file name
        retry_save=1;
        while(retry_save==1)
            try
                save(strcat(computer_name,'.mat'),'computer_name')
                pause(0.1);
                retry_save=0;
            catch
                retry_save=1;
                pause(0.1)
                disp_progress(app,strcat('Error Server Status: Line 38: Cant save computer name'))
            end
        end

        %%%%%%%%%%Go back to the sim_folder
        retry_cd=1;
        while(retry_cd==1)
            try
                cd(sim_folder)
                pause(0.1);
                retry_cd=0;
            catch
                retry_cd=1;
                pause(0.1)
                disp_progress(app,strcat('Error Server Status: Line 52: Cant get back to the sim_folder -->',sim_folder))
            end
        end

        disp_progress(app,strcat('Successfully Updated Server Status'))
        toc;
    end
end

end