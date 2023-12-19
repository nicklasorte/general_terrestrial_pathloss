function [dBloss,prop_mode]=ITMP2P_mechanism_rev4_sea(app,array_tx_pts,rx_pts,reliability,confidence,radar_height,FreqMHz)


        if isdeployed==1
            NET.addAssembly(which('SEADLib.dll'));
        else
            NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
        end

        itmp=ITMAcs.ITMP2P;
        TerHandler=int32(1); % 0 for GLOBE, 1 for USGS
        TerDirectory='C:\USGS\';

        %%%%%Mode of Variability (MDVAR)	13 (broadcast p2p)
        itmp = ITMAcs.ITMP2P;
        Dielectric=81.0;
        Conduct=5.0;
        Refrac=350.0;
        RadClim=int32(7); % 1 Equatorial, 2 Continental Subtorpical, 3 Maritime Tropical, 4 Desert, % 5 Continental Temperate, 6 Maritime Over Land, 7 Maritime Over Sea
        RelPct=reliability/100; %0.5;
        ConfPct=confidence/100;
        TxHtm=radar_height;
        Tpol=1;
        [num_pts,~]=size(array_tx_pts);
        num_rel=length(reliability);

        RxLat=rx_pts(1);
        RxLon=rx_pts(2);
        RxHtm=rx_pts(3);





        %%%%Preallocate
        dBloss=NaN(num_pts,num_rel);
        prop_mode=NaN(num_pts,1);
        for pt_idx=1:1:num_pts  %%%%For Now, send in CBSD one at a time

            disp_progress(app,strcat('ITM:',num2str(pt_idx/num_pts*100),'%'))

            TxLat=array_tx_pts(pt_idx,1);
            TxLon=array_tx_pts(pt_idx,2);
            TxHtm=array_tx_pts(pt_idx,3);


            try
                clear temp_dBloss;
                [temp_dBloss,propmodeary]=itmp.ITMp2pAryRels(TxHtm,RxHtm,Refrac,Conduct,Dielectric,FreqMHz,RadClim,Tpol,ConfPct,RelPct,TxLat,TxLon,RxLat,RxLon,TerHandler,TerDirectory);
                prop_mode(pt_idx)=double(propmodeary);

                %%%% 0 LOS, 4 Single Horizon, 5 Difraction Double Horizon, 8 Double Horizon, 9 Difraction Single Horizon, 6 Troposcatter Single Horizon, 10 Troposcatter Double Horizon, 333 Error
            catch
                temp_dBloss=1000;
                prop_mode(pt_idx)=999;
                save(strcat('ERROR_NaN_prop_CBSDnum',num2str(pt_idx),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'temp_dBloss')

                % % %         'ITM Error'
                % % %         pause;
            end
            dBloss(pt_idx,:)=double(temp_dBloss);

        end


end