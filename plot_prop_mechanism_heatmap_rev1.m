function plot_prop_mechanism_heatmap_rev1(app,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,min_prop_data,base_protection_pts)


%%%%%%%%%%%%%%%%Propagation Mechanism Heat Map: ITM      'plot the tropo/diff/Los map next'  %%%min_prop_data
temp_prop_grid_pts=sim_array_list_bs(:,[1,2]);
merge_los_idx=find(min_prop_data==1);
merge_diff_idx=find(min_prop_data==2);
merge_tropo_idx=find(min_prop_data==3);
mode_color_set=plasma(3);

f1=figure;
AxesH = axes;
hold on;
scatter(temp_prop_grid_pts(1,2),temp_prop_grid_pts(1,1),10,1,'filled');
scatter(temp_prop_grid_pts(1,2),temp_prop_grid_pts(1,1),10,3,'filled');
scatter(temp_prop_grid_pts(merge_tropo_idx,2),temp_prop_grid_pts(merge_tropo_idx,1),10,min_prop_data(merge_tropo_idx),'filled');
scatter(temp_prop_grid_pts(merge_diff_idx,2),temp_prop_grid_pts(merge_diff_idx,1),10,min_prop_data(merge_diff_idx),'filled');
scatter(temp_prop_grid_pts(merge_los_idx,2),temp_prop_grid_pts(merge_los_idx,1),10,min_prop_data(merge_los_idx),'filled');
plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
%plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
cbh = colorbar;
ylabel(cbh, 'Prop Mode')
colormap(f1,mode_color_set)
cbh.Ticks = linspace(1,3, 7);
cbh.TickLabels ={'','LOS','','DIFF','','TROPO',''};
grid on;
xlabel('Longitude')
ylabel('Latitude')
title({strcat('Propagation Mechanism')})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
pause(0.1)
filename1=strcat('Prop_mode_Heatmap','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
saveas(gcf,char(filename1))
pause(0.1);
close(f1)
end