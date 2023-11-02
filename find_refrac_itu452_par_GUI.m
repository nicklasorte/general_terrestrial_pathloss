function [refractivity_value]=find_refrac_itu452_par_GUI(app,list_cbsd,sim_pt,data_N050)
            [t_mlat,t_mlon]=track2(list_cbsd(1),list_cbsd(2),sim_pt(1),sim_pt(2),[],'degrees',3);
            refractivity_value=get_txt_value_GUI(app,t_mlat(2),t_mlon(2),data_N050); %Gets the Climate of each point
        end