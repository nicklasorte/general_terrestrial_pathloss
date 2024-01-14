function [dBloss,prop_mode]=P2001_mechanism_rev1(app,sim_array_list_bs,sim_pt,reliability,FreqMHz,Tpol,parallel_flag)

if parallel_flag==0
    disp_progress(app,strcat('Starting P2001 . . . '))
end


[num_bs,~]=size(sim_array_list_bs);
num_rel=length(reliability);

if isdeployed==1
    NET.addAssembly(which('SEADLib.dll'));
else
    NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
end


% % % %      % Calculations based on Terrain Retrievals
% % % % % NOTE: The ITS code expects support TXT file in the subdirectory ..\DIgitalMaps
terpath='C:\USGS\';
terhandler = 1;
pathp2001 = terpath;
FreqGHz=FreqMHz/1000

Gtx=0;
Grx=0;
FlagVP =1;% Tpol;%%%%1%[1, 0];

RxHtm=sim_pt(3);
RxLat=sim_pt(1);
RxLon=sim_pt(2);


%%%%Preallocate
dBloss=NaN(num_bs,num_rel);
prop_mode=NaN(num_bs,1);
for i=1:1:num_bs  %%%%For Now, send in CBSD one at a time
    
    if parallel_flag==0
        disp_progress(app,strcat('P2001:',num2str(i/num_bs*100),'%'))
    end
    
    TxLat=sim_array_list_bs(i,1);
    TxLon=sim_array_list_bs(i,2);
    TxHtm=sim_array_list_bs(i,3);

    %tic;
    for j=1:1:num_rel
        Tpc=reliability(j);

        %try
            clear temp_dBloss;
            temp_dBloss=double(SEADLib.SEADLib.P2001FN(FreqGHz,Tpc,TxLat, TxLon, RxLat, RxLon,TxHtm,RxHtm,Gtx,Grx,FlagVP,terhandler,terpath,pathp2001));
            %%temp_dBloss=double(SEADLib.SEADLib.ITS_P2001(FreqGHz,Tpc,TxLat,TxLon,RxLat,RxLon,TxHtm,RxHtm,Gtx,Grx,FlagVP==1,terpath,terhandler));

            %%%%%%%%%prop_mode(i)=double(propmodeary);

%         catch
%             temp_dBloss=1000;
%             prop_mode(i)=999;
%             save(strcat('ERROR_NaN_prop_CBSDnum',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'temp_dBloss')
% 
%             sim_array_list_bs(i,:)
%             sim_pt
%             'P2001 error'
%             pause;
%         end
        dBloss(i,j)=double(temp_dBloss);
    end
    %toc;

end

end