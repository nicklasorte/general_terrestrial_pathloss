clear;
clc;
close all;
close all force;
app=NaN(1);  %%%%%%%%This is for me and APPs
format shortG
top_start_clock=clock;
folder1='C:\Local Matlab Data\General_Terrestrial_Pathloss'  
cd(folder1)
addpath(folder1)


%%%%%%%%%%%%%%%%%%%%%%%ITM Test
parallel_flag=0
FreqMHz=2700; %%%%%%%%MHz
reliability=50;
confidence=50;
Tpol=1; %%%polarization for ITM

sim_array_list_bs=horzcat(40.7613391,-111.8462915,40) %%%%%Utah Tx
sim_pt=horzcat(40.811,-111.97,8)  %%%%%%%%STLC ARS-9


[pathloss,prop_mode]=ITMP2P_mechanism_rev4_embed_height(app,sim_array_list_bs,sim_pt,reliability,confidence,FreqMHz,Tpol,parallel_flag)


% % pathloss =
% % 
% %        122.49
% % 
% % 
% % prop_mode =
% % 
% %      0



