function [dBloss,prop_mode]=ITMP2P_mechanism_rev3(app,sim_array_list_bs,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag)

if parallel_flag==0
    disp_progress(app,strcat('Starting ITM . . . '))
end


[num_bs,~]=size(sim_array_list_bs);
num_rel=length(reliability);

if isdeployed==1
    NET.addAssembly(which('SEADLib.dll'));
else
    NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
end

itmp=ITMAcs.ITMP2P;
TerHandler=int32(1); % 0 for GLOBE, 1 for USGS
TerDirectory='C:\USGS\';

%%%%%Mode of Variability (MDVAR)	13 (broadcast p2p)

%Climate	Derived by using ITU-R.P.617
%%%Persisent Load
retry_load=1;
while(retry_load==1) %%%This will continue to pin the move_list_function
    try
        load('TropoClim.mat','TropoClim')
        retry_load=0;
    catch
        retry_load=1;
        if parallel_flag==0
            disp_progress(app,strcat('Error in ITM --> Loading TropoClim'))
        end
        error=NaN(1);
        save(strcat('ERROR_LOAD_TropoClim',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'error')
        pause(1)
    end
end
TropoClim_data=int32(TropoClim);

try
    %Calculate Radar Radio Climate
    tropo_value_radar=get_txt_value_GUI(app,sim_pt(1),sim_pt(2),TropoClim_data); %Gets the Climate of each point
catch
    tropo_value_radar=int32(7);
    % 1 Equatorial, 2 Continental Subtorpical, 3 Maritime Tropical, 4 Desert, 5 Continental Temperate, 6 Maritime Over Land, 7 Maritime Over Sea
    save(strcat('ERROR_tropo_value_radar_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'tropo_value_radar')
end

%%%Surface refractivity: Derived by using ITU-R.P.452
%%%Persisent Load
retry_load=1;
while(retry_load==1) %%%This will continue to pin the move_list_function
    try
        load('data_N050.mat','data_N050')
        retry_load=0;
    catch
        retry_load=1;
        if parallel_flag==0
            disp_progress(app,strcat('Error in ITM --> Loading data_N050'))
        end
        error=NaN(1);
        save(strcat('ERROR_LOAD_data_N050',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'error')
        pause(1)
    end
end

data_N050_data=data_N050;

Dielectric=25.0;
Conduct=0.02;

ConfPct=confidence/100;
RelPct=reliability/100;

RxHtm=radar_height;
RxLat=sim_pt(1);
RxLon=sim_pt(2);

%%%%Preallocate
dBloss=NaN(num_bs,num_rel);
prop_mode=NaN(num_bs,1);
for i=1:num_bs  %%%%For Now, send in CBSD one at a time
    
    if parallel_flag==0
        disp_progress(app,strcat('ITM:',num2str(i/num_bs*100),'%'))
    end
    
    TxLat=sim_array_list_bs(i,1);
    TxLon=sim_array_list_bs(i,2);
    TxHtm=sim_array_list_bs(i,3);
    
    try
        %Calculate Radio Climate
        tropo_value=find_tropo_itu617_parfor_GUI(app,sim_array_list_bs(i,1:2),TropoClim_data,tropo_value_radar);
        RadClim=int32(tropo_value); % 1 Equatorial, 2 Continental Subtorpical, 3 Maritime Tropical, 4 Desert, 5 Continental Temperate, 6 Maritime Over Land, 7 Maritime Over Sea
    catch
        RadClim=int32(5);
        save(strcat('ERROR_RadClim_CBSDnum',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'RadClim')
    end
    
    try
        %Calculate Refractivity
        Refrac=find_refrac_itu452_par_GUI(app,sim_array_list_bs(i,1:2),sim_pt,data_N050_data);
    catch
        Refrac=301;
        save(strcat('ERROR_Refrac_CBSDnum',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'Refrac')
    end
    
    
% % % %%%%%%%%%%%%%%Debug Code
% % % TxHtm
% % % RxHtm
% % % Refrac
% % % Conduct
% % % Dielectric
% % % FreqMHz
% % % RadClim
% % % Tpol
% % % ConfPct
% % % RelPct
% % % TxLat
% % % TxLon
% % % RxLat
% % % RxLon
% % % TerHandler
% % % TerDirectory   
% % % [temp_dBloss]=itmp.ITMp2pAryRels(TxHtm,RxHtm,Refrac,Conduct,Dielectric,FreqMHz,RadClim,Tpol,ConfPct,RelPct,TxLat,TxLon,RxLat,RxLon,TerHandler,TerDirectory)
% % % %%%%%%%%%%%%%%%Debug Code


    try
        clear temp_dBloss;
        [temp_dBloss,propmodeary]=itmp.ITMp2pAryRels(TxHtm,RxHtm,Refrac,Conduct,Dielectric,FreqMHz,RadClim,Tpol,ConfPct,RelPct,TxLat,TxLon,RxLat,RxLon,TerHandler,TerDirectory);
        prop_mode(i)=double(propmodeary);

 %%%% 0 LOS, 4 Single Horizon, 5 Difraction Double Horizon, 8 Double Horizon, 9 Difraction Single Horizon, 6 Troposcatter Single Horizon, 10 Troposcatter Double Horizon, 333 Error
    catch
        temp_dBloss=1000;
        prop_mode(i)=999;
        save(strcat('ERROR_NaN_prop_CBSDnum',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'temp_dBloss')

% % %         'ITM Error'
% % %         pause;
    end
    dBloss(i,:)=double(temp_dBloss);

end

end