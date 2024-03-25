function [num_chunks,cell_sim_chuck_idx,array_rand_chunk_idx]=rand_chunks_rev1(app,sim_array_list_bs)

[num_bs,~]=size(sim_array_list_bs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we define the num_chunks
%dyn_chunks=ceil(num_bs/1000)
num_chunks=24%max([24,dyn_chunks])

chuck_size=floor(num_bs/num_chunks);
cell_sim_chuck_idx=cell(num_chunks,1);

for sub_idx=1:1:num_chunks  %%%%%%Define the sim idxs
    if sub_idx==num_chunks
        start_idx=(sub_idx-1).*chuck_size+1;
        stop_idx=num_bs;
        temp_sim_idx=start_idx:1:stop_idx;
    else
        start_idx=(sub_idx-1).*chuck_size+1;
        stop_idx=sub_idx.*chuck_size;
        temp_sim_idx=start_idx:1:stop_idx;
    end
    cell_sim_chuck_idx{sub_idx}=temp_sim_idx;
end
%%%%%Check
missing_idx=find(diff(horzcat(cell_sim_chuck_idx{:}))>1);
num_idx=length(unique(horzcat(cell_sim_chuck_idx{:})));
if ~isempty(missing_idx) || num_idx~=num_bs
    'Error:Check Chunk IDX'
    pause;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Randomize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the chunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%order

[tf_ml_toolbox]=check_ml_toolbox(app);
if tf_ml_toolbox==1
    array_rand_chunk_idx=randsample(num_chunks,num_chunks,false);
else
    array_rand_chunk_idx=randperm(num_chunks);
end

end