function [dBloss,prop_mode]=TIREM5_mechanism_angles_rev4(app,sim_array_list_bs,sim_pt,FreqMHz,parallel_flag)

if parallel_flag==0
    disp_progress(app,strcat('Starting TIREM 5 . . . '))
end


if isdeployed==1
    NET.addAssembly(which('SEADLib.dll'));
    if parallel_flag==0
        disp_progress(app,strcat('Inside TIREM5, succesfully initialized net assembly SEADLib.dll'))
    end

    tiremSetup('C:\USGS\TIREM5') 
    if parallel_flag==0
        disp_progress(app,strcat('Inside TIREM5, succesfully initialized tiremSetup'))
    end

% %     addpath('C:\USGS\TIREM5')
% %     which_str=which('libtirem3.dll');
% %     %%%%Now isolate the folder
% %     temp_strsplit = split(which_str,'\');
% %     temp_strsplit(end)=[];
% %     %%%tiremSetup('C:\USGS\TIREM5') 
% %     tiremSetup(fullfile(temp_strsplit{:}))
else
    NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
    tiremSetup('C:\USGS\TIREM5')  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Change this to the folder of the TIREM dlls 
end


RxHtm=sim_pt(3);
RxLat=sim_pt(1);
RxLon=sim_pt(2);

FreqHz=FreqMHz*1000000; %%%%%Hz

%%%%Preallocate
[num_bs,~]=size(sim_array_list_bs);
dBloss=NaN(num_bs,1);
prop_mode=cell(num_bs,1);
for i=1:1:num_bs  %%%%For Now, send in tx one at a time
    if parallel_flag==0
        disp_progress(app,strcat('TIREM:',num2str(i/num_bs*100),'%'))
    end
    
    TxLat=sim_array_list_bs(i,1);
    TxLon=sim_array_list_bs(i,2);
    TxHtm=sim_array_list_bs(i,3);

    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Terrain Profile
        USGS3Secp = TerrainPcs.USGS;
        CoordTx = TerrainPcs.Geolocation(TxLat,TxLon);
        CoordRx = TerrainPcs.Geolocation(RxLat,RxLon);
        USGS3Secp.TerrainDataPath="C:\USGS";
        Elev=double(USGS3Secp.GetPathElevation(CoordTx,CoordRx,90,true));  %%%%%%%%%This is the "z" equivalent
        tf_terrain_error=0;
    catch
        save(strcat('ERROR_Terrain_',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'sim_pt')
        tf_terrain_error=1;
    end

    if tf_terrain_error==0
        try
            temp_dist_km=deg2km(distance(TxLat,TxLon,RxLat,RxLon));
            r=linspace(0,temp_dist_km*1000,length(Elev));
            z=Elev;
            [tirem_pl_terrain,tirem_info_terrain]=tirempl(r,z,FreqHz,'TransmitterAntennaHeight',TxHtm,'ReceiverAntennaHeight',RxHtm);
        catch
            save(strcat('ERROR_TIREM_',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'sim_pt')
            tirem_pl_terrain=1000;
            tirem_info_terrain='Error';
        end
    else
        tirem_pl_terrain=1000;
        tirem_info_terrain='Error';
    end

    dBloss(i,1)=tirem_pl_terrain;
    prop_mode{i}=tirem_info_terrain;
end

end