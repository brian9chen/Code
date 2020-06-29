%%%%%%%%
% Script to plot record section for one event on multiple stations
% 
%%%%%%%%
%%% Changes for new run
%%% 1. The load data and info files section, lines 16,17, 19 and 22
%%% 2. tile of the figure at the very end on line 158
%%%%%%%%
% Author: Axel Wang
% Date: 2019/06/27
%%%%%%%%

clear all; close all
%%
%----------------------- Load data and info files ---------------
load('H017_LF_data.mat');
% For ZH events, add _HF_
data = H017_LF_data;

stn = importdata('H017_LF_stn.txt');
[out,I] = sortrows(stn,2)
SnLgRatio = out(:,3);


info = importdata('H017_LF_info.txt');
dist = info(:,1);
ntp = info(:,2);
ntsn_min = info(:,3);
ntsn = info(:,4);
ntlg_min = info(:,5);
ntlg = info(:,6);
ntn_min = info(:,7);
ntn = info(:,8);

% get distance in integers
dist_int = round(dist);

% velocities:
vpn = 8.1;

vsn = 4.0;
vlg = 2.8;

vsn_max = 4.8;
vlg_max = 3.6;

% initialize time array we want to look at
T = dt_out:dt_out:1000;

% numer of traces
data_size = size(data);
tr_num = data_size(2);

% horizontal index array
horiz = 1:1.5:1.5*tr_num;

% Save data for GMT
%1.full cutted trace
seis =[];
%2.Sn window
sn_win =[];
%3. Lg window
lg_win =[];
%4. Noise window
noise_win = [];
%----------------------- Make the plot  ---------------

figure(1)
for n= 1:tr_num

    k = I(n);
    
    % Set trace begin time to 30s before picked Pn
    T_begin = T(ntp(k)-ceil(30/dt_out));
    % Index corresponding to T_begin
    idx = ceil(T_begin/dt_out);
    % Cut out corresponding data and normalize to self
%     TD_cut = dist(n)+data(idx:length(T),k)*10^7*3;   
     TD_cut = horiz(n)+data(idx:length(T),k)./max(abs(data(idx:length(T),k)));

    % Shift the time series (minus T_begin to make the time series start
    % from zero)
    T_plot = T(idx:end)-T_begin;
       
    % Cut out Sn and Lg windows
    idxsn_min = ntsn_min(k)-idx;
    idxsn = ntsn(k)-idx;
    TSn = T_plot(idxsn_min:idxsn);
    Sn = TD_cut(idxsn_min:idxsn);
    
    idxlg_min = ntlg_min(k)-idx;
    idxlg = ntlg(k)-idx;
    TLg = T_plot(idxlg_min:idxlg);
    Lg = TD_cut(idxlg_min:idxlg);
    
    % Cut out the noise window
    idxn_min = ntn_min(k)-idx;
    idxn = ntn(k)-idx;
    Tn = T_plot(idxn_min:idxn);
    noise = TD_cut(idxn_min:idxn);
    
    % Plot
    plot(TD_cut,T_plot,'k');
    hold on
    plot(Sn,TSn,'r','LineWidth',2)
    hold on
    plot(Lg,TLg,'c','LineWidth',2)
    hold on
    plot(noise,Tn,'g','LineWidth',1)
    hold on
    
    % Save data for GMT
    % Full seismogram
    temp_seis =[];
    temp_seis(:,1)=ones(size(TD_cut))*horiz(n);
    temp_seis(:,2)=T_plot;
    temp_seis(:,3)=TD_cut-horiz(n);
    
    seis = [seis ; temp_seis];
    
    % Sn window
    temp_sn =[];
    temp_sn(:,1)=ones(size(Sn))*horiz(n);
    temp_sn(:,2)=TSn;
    temp_sn(:,3)=Sn-horiz(n);
    
    sn_win = [sn_win ; temp_sn];
    
    % Lg window
    temp_lg =[];
    temp_lg(:,1)=ones(size(Lg))*horiz(n);
    temp_lg(:,2)=TLg;
    temp_lg(:,3)=Lg-horiz(n);
    
    lg_win = [lg_win ; temp_lg];
    
     % Noise window
    temp_noise =[];
    temp_noise(:,1)=ones(size(noise))*horiz(n);
    temp_noise(:,2)=Tn;
    temp_noise(:,3)=noise-horiz(n);
    
    noise_win = [noise_win ; temp_noise];
    
    
    
    
end

hp=line([0 1.5*tr_num+1], [30 30]);
set(hp,'LineWidth',1,'Color','b','LineWidth',2);
 
xlim([0 1.5*tr_num+1])
ylim([0 250])
xticks(horiz)
xticklabels(num2str(dist_int(I)))
xtickangle(45)
title('H017 LF Record Section')
xlabel('Epi. distance (km)')
ylabel('Reduced time (s)')
set(gca,'FontSize',15)
set(gca,'GridLineStyle',"--")
set(gca,'GridAlpha',0.6)
set(gcf,'Position',[0 0 1500 1000])
set(gca,'YGrid','on','XGrid','off')

%% Save data for GMT
% save x-axis labels: bottom
xlabel = [horiz' dist_int(I)];
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/xlabel_LF_bot_H017.txt','w');
fprintf(fileID,'%1.4f %u \n', xlabel');
fclose(fileID);

%save x-axis labels: top
xlabel = [horiz' SnLgRatio];
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/xlabel_LF_top_H017.txt','w');
fprintf(fileID,'%1.4f %1.3f \n', xlabel');
fclose(fileID);

%save the data for Seismogram
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/seis_LF_H017.txt','w');
fprintf(fileID,'%1.2f %3.4f %1.4f\n', seis');
fclose(fileID);

% Sn window
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/sn_LF_H017.txt','w');
fprintf(fileID,'%1.2f %3.4f %1.4f\n', sn_win');
fclose(fileID);

% Lg window
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/lg_LF_H017.txt','w');
fprintf(fileID,'%1.2f %3.4f %1.4f\n', lg_win');
fclose(fileID);

%Noise window
fileID = fopen('/Users/axelwang/Research/TibetDeep/LgSn/GMT/Events/noise_LF_H017.txt','w');
fprintf(fileID,'%1.2f %3.4f %1.4f\n', noise_win');
fclose(fileID);





