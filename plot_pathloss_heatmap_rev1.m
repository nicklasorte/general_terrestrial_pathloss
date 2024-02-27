function plot_pathloss_heatmap_rev1(app,data_label1,string_prop_model,grid_spacing,min_pl_data,sim_array_list_bs,base_protection_pts)

                 %%%%%%%%%%%%%%%%min_pl_data Heat Map
                mode_color_set_angles=plasma(100);
                f1=figure;
                AxesH = axes;
                hold on;
                scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,ceil(max(min_pl_data)),'filled');
                scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,floor(min(min_pl_data)),'filled');
                scatter(sim_array_list_bs(:,2),sim_array_list_bs(:,1),10,min_pl_data,'filled');
                plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
                %plot(base_protection_pts(:,2),base_protection_pts(:,1),'sb','LineWidth',3,'DisplayName','Federal System')
                cbh = colorbar;
                ylabel(cbh, 'Path Loss [dB]')
                colormap(f1,mode_color_set_angles)
                grid on;
                xlabel('Longitude')
                ylabel('Latitude')
                title({strcat('Path Loss')})
                plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                pause(0.1)
                filename1=strcat('Pathloss_Heatmap','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
                saveas(gcf,char(filename1))
                pause(0.1);
                close(f1)

end