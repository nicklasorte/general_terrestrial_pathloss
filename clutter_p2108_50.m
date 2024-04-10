function  [array_clutter]=clutter_p2108_50(app,FreqMHz)

freq_GHz=FreqMHz/1000
dist_km=0.25:0.01:2;  %%%%%%km Can't exceed 2km
dist_km=0:0.01:2;  %%%%%%km Can't exceed 2km

%%%%ITU-R Clutter 3.2 (No Clutter Loss for less than 250m), Use this for the Base Station Clutter Loss, Use 3.1 for Handset Clutter
Ll=-2*log10(10^(-5*log10(freq_GHz)-12.5)+10^(-16.5)); %Equation 4a
Ls=32.98+(23.9*log10(dist_km))+(3*log10(freq_GHz));  %%%Equation 5a

%sigma_l=4; %%%%%Equation 4b
%sigma_s=6; %%%%%Equation 5b
%sigma_cb=sqrt(((sigma_l^2)*10^(-0.2*Ll)+(sigma_s^2)*10.^(-0.2*Ls))./(10^(-0.2*Ll)+10.^(-0.2*Ls)));


Lctt=-5*log10(10^(-0.2*Ll)+10.^(-0.2*Ls));
% % size(Lctt)
% %  max(Lctt)

idx_zero=find(dist_km<0.25);
Lctt(idx_zero)=0;

array_clutter=horzcat(dist_km',Lctt');

% % round_array_clutter=round(array_clutter,1);
% % [~,uni_idx]=unique(round_array_clutter(:,1));
% % uni_round_clutter=round_array_clutter(uni_idx,:)
% % 
% % clutter_table=array2table(uni_round_clutter);
% % clutter_table.Properties.VariableNames={'Distance_km' 'Clutter_dB'}
% % tabel_filename1=strcat('Clutter_',num2str(FreqMHz),'.xlsx');
% % writetable(clutter_table,tabel_filename1);
% % 
% % 
% % figure;
% % hold on;
% % plot(dist_km,Lctt)
% % grid on;
% % xlabel('Distance [km]')
% % ylabel('Median Clutter [dB]')
% % filename1=strcat('Clutter_',num2str(FreqMHz),'.png');
% % pause(0.1)
% % saveas(gcf,char(filename1))

end