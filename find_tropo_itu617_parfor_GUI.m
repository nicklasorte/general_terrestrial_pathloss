function [tropo_value]=find_tropo_itu617_parfor_GUI(app,single_list_cbsd,TropoClim,tropo_value_radar)
            temp_tropo=get_txt_value_GUI(app,single_list_cbsd(1),single_list_cbsd(2),TropoClim); %Gets the Climate of each point
            if temp_tropo==0 && tropo_value_radar~=0
                tropo_value=tropo_value_radar;
            end
            if temp_tropo==0 && tropo_value_radar==0
                tropo_value=0;
            end
            if temp_tropo~=0 && tropo_value_radar==0
                tropo_value=temp_tropo;
            end
            if temp_tropo~=0 && tropo_value_radar~=0
                tropo_value=min([temp_tropo,tropo_value_radar]);
            end
            if tropo_value==0 %%%%%%%%%For ITM, 7 is Sea but is 0 for itu617
                tropo_value=7;
            end
        end