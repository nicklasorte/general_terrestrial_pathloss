function plot_pathloss_heatmat_reli_rev2(app,array_reliability_check,min_pl_data,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,base_protection_pts)

               num_rels=length(array_reliability_check);

               for rel_idx=1:1:num_rels
                    temp_rel=array_reliability_check(rel_idx);

                    temp_pl_data=min_pl_data(:,rel_idx);

                   %%%%%%%%%%%%%%%%min_pl_data Heat Map
                   mode_color_set_angles=plasma(100);
                   f1=figure;
                   AxesH = axes;
                   hold on;
                   scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,ceil(max(temp_pl_data)),'filled');
                   scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,floor(min(temp_pl_data)),'filled');
                   scatter(sim_array_list_bs(:,2),sim_array_list_bs(:,1),10,temp_pl_data,'filled');
                   plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
                   cbh = colorbar;
                   ylabel(cbh, 'Path Loss [dB]')
                   colormap(f1,mode_color_set_angles)
                   grid on;
                   xlabel('Longitude')
                   ylabel('Latitude')
                   title({strcat('Path Loss')})
                   plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                   pause(0.1)
                   filename1=strcat('Pathloss_Heatmap','_',data_label1,'_',string_prop_model,'_',num2str(temp_rel),'%_',num2str(grid_spacing),'km.png');
                   saveas(gcf,char(filename1))
                   pause(0.1);
                   close(f1)

               end
end