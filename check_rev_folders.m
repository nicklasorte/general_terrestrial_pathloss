function [sim_number,folder_names,num_folders]=check_rev_folders(app,rev_folder)

cd(rev_folder)
pause(0.1)
split_rev=strsplit(rev_folder,'\');
sim_string=strsplit(split_rev{end},'Rev');
sim_number=str2num(sim_string{end})
pause(0.1);
temp_files=dir(rev_folder);
dirFlags=[temp_files.isdir];
subFolders=temp_files(dirFlags);
subFolders(1:2)=[];
cell_subFolders=struct2cell(subFolders);
folder_names=cell_subFolders(1,:)';
num_folders=length(folder_names);


end