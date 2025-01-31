function [pathloss,cell_prop_mode]=load_pathloss_propmode_rev1(app,string_prop_model,point_idx,sim_number,data_label1)


file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
file_name_prop_mode=strcat(string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
retry_load=1;
while(retry_load==1)
    try
        load(file_name_pathloss,'pathloss')
        load(file_name_prop_mode,'prop_mode')
        retry_load=0;
    catch
        retry_load=1;
        pause(1)
    end
end

%%%%%%%%%%Clean up the prop_mode
if strcmp(string_prop_model,'TIREM')
    num_cells=length(prop_mode);
    cell_prop_mode=cell(num_cells,1);
    for prop_idx=1:1:num_cells
        temp_structure=prop_mode{prop_idx};
        cell_prop_mode{prop_idx}=temp_structure.PropagationMode;
    end
elseif strcmp(string_prop_model,'ITM')
    num_cells=length(prop_mode);
    cell_prop_mode=cell(num_cells,1);
    for prop_idx=1:1:num_cells
        num_prop_mode=prop_mode(prop_idx);
        if num_prop_mode==0
            temp_prop_mode='LOS';
        elseif num_prop_mode==4
            temp_prop_mode='Single Horizon';
        elseif num_prop_mode==5
            temp_prop_mode='Difraction Double Horizon';
        elseif num_prop_mode==8
            temp_prop_mode='Double Horizon';
        elseif num_prop_mode==9
            temp_prop_mode='Difraction Single Horizon';
        elseif num_prop_mode==6
            temp_prop_mode='Troposcatter Single Horizon';
        elseif num_prop_mode==10
            temp_prop_mode='Troposcatter Double Horizon';
        elseif num_prop_mode==333
            temp_prop_mode='Error';
        else
            'Undefined Propagation Mode'
            pause;
        end
        cell_prop_mode{prop_idx}=temp_prop_mode;
    end
else
    'Error: Unknown propagation model'
    pause;
end
end
