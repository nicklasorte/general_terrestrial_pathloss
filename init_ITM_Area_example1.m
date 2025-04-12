clear;
clc;
close all;
close all force;
format shortG
top_start_clock=clock;
folder1='C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\General_Terrestrial_Pathloss';
cd(folder1)
addpath(folder1)


reliability=50
tx_height_m=10
rx_height_m=5
DistKm=100
DeltaH=30
FreqMHz=3500


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
[temp_dBloss, propmode, errnum] = itma.area(ModVar,DeltaH,TxHtm,RxHtm,DistKm,TxSc,RxSc,Dielectric,Conduct,Refrac,FreqMHz,RadClim,Polarity,TimePct,LocPct,ConfPct,dBloss, propmode, errnum);
temp_dBloss=double(temp_dBloss)




end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end