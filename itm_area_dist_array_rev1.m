function [array_dist_pl]=itm_area_dist_array_rev1(app,reliability,tx_height_m,rx_height_m,max_itm_dist_km,FreqMHz)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Should probably pull this out of the loop so we don't have to do it 4,000 times
        %%%%%%%%%%But it might change due to receiver height
        %%%%%%%%%%Find the ITM Area Pathloss for the distance init_itm_dist_km
        NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
        itma = ITMcsCls.ITMcsCls;
        ModVar = int32(2); % 0 Single, 1 Individual, 2 Mobile, 3 Broadcast
        DeltaH = 30.0;
        TxSc = int32(1); % 0 Random, 1 Careful, 2 Very Careful
        RxSc = int32(0); % 0 Random, 1 Careful, 2 Very Careful
        Dielectric = 15.0;
        Conduct = 0.005;
        Refrac = 301.0;
        RadClim = int32(5); % 1 Equatorial, 2 Continental Subtorpical, 3 Maritime Tropical, 4 Desert, % 5 Continental Temperate, 6 Maritime Over Land, 7 Maritime Over Sea
        Polarity = 1; % 0 Horizontal, 1 Vertical
        TimePct = min(reliability)/100;
        LocPct = min(reliability)/100;
        ConfPct = min(reliability)/100;
        dBloss = 0.0;
        propmode = int32(0); % 0 LOS, 4 Single Horizon, 5 Difraction Double %  Horizon, 8 Double Horizon, 9 Difraction Single Horizon, 6 Troposcatter  %  Single Horizon, 10 Troposcatter Double Horizon, 333 Error
        errnum = int32(0);
        TxHtm=tx_height_m;
        RxHtm=rx_height_m;

       array_dist_km=1:1:max_itm_dist_km;
       [num_dist]=length(array_dist_km);
       array_dist_pl=NaN(num_dist,2);
       array_dist_pl(:,1)=array_dist_km';
       for n=1:1:num_dist
           DistKm=array_dist_km(n);
           [temp_dBloss, propmode, errnum] = itma.area(ModVar,DeltaH,TxHtm,RxHtm,DistKm,TxSc,RxSc,Dielectric,Conduct,Refrac,FreqMHz,RadClim,Polarity,TimePct,LocPct,ConfPct,dBloss, propmode, errnum);
           array_dist_pl(n,2)=double(temp_dBloss);
       end

end