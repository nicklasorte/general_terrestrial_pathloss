function [workers,max_cores]=recommend_num_workers(app)

%%%%%%%%%Find the number of cores
max_cores=feature('numcores');

%%%%%Find the memory
[userview,systemview]=memory;
cell_memory= struct2cell(systemview.PhysicalMemory);
total_bytes=cell_memory{2};
total_ram=floor(total_bytes/(1.06e+9));  %%%%Really: 1.074e+9
ram_workers=floor(total_ram/2);
workers=min([ram_workers,max_cores]);
%%%%%Recommend something about total min([RAM/2GB or max_cores])
end