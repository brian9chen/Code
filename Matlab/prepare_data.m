%%%%%%%%
% Script to 
% compare the relative amplitudes of Sn and Lg and save event number based
% on this. 
% also saves data and arrival times of Pn/Pg, Sn, Lg for group plot.
%%%%%%%%
%%% Changes for new run:
%%% 1. Event name on line 17. Directory on line 20.
%%% 2. Variable names on line 233,241
%%% 3. Variable name on line 245
%%%%%%%%
% Author: Axel Wang 
% Date: 2019/07/07
%%%%%%%%
clear all; close all
%% Event ID
EVENT = 'K1';

%% Input Directory
% dir=strcat('C:/Users/23brianc/Documents/Internship2020/Code/Matlab/Data/', EVENT);
% dir=strcat('./Data/', EVENT);
%% Read N&Z components file names and corresponding depth
% f = fullfile(dir,'evtlst.txt');
% fid = fopen(fullfile(dir,'evtlst.txt'));
% Input = textscan(fid,'%s %s %s %f');

dir = '/Users/23brianc/Documents/Internship2020/Code/Matlab/Data/K1';
fid = fopen('/Users/23brianc/Documents/Internship2020/Code/Matlab/Data/K1/evtlst.txt');
Input = textscan(fid,'%s %s %s %f');

Sacnm_Z = Input{1};
Sacnm_N = Input{2};
Sacnm_E = Input{3};
Depth = Input{4};
fclose(fid);
%% Data Processing
n_sac = length(Sacnm_Z);
% Resample rate (see below)
dt_out=0.01;


% File IDs
STN = fopen(strcat(EVENT,'_LF_stn.txt'),'w');
INFO = fopen(strcat(EVENT,'_LF_info.txt'),'w');
K1_LF_data = zeros(100000,n_sac);



% Specify filter passbands
    % Low passband 
    lowpass=2;
    highpass=1;
    

for k=1:n_sac
    
%-------------------- Reading and Raw Data -----------------     
    % Read in data
    sacnm_z = Sacnm_Z{k};
    sacnm_n = Sacnm_N{k};  
    sacnm_e = Sacnm_E{k};  
    sacst_z = SACST_fread({fullfile(dir,sacnm_z)});
    sacst_n = SACST_fread({fullfile(dir,sacnm_n)});
    sacst_e = SACST_fread({fullfile(dir,sacnm_e)});
    
    % Full Time Series 
    dt_in = sacst_z.delta;
    b_in = sacst_z.b;
    npts_in = sacst_z.npts;
    o_in = sacst_z.o;
    e_in = b_in+(npts_in-1)*dt_in;
    T = b_in:dt_in:e_in;
                
    % Original Data
    Z = sacst_z.data;
    N = sacst_n.data;
    E = sacst_e.data;
    
    % Make sure all data components have the same length by cutting them 
    % down to the shortest arrary.     
 if length(T) ~= length(N) | length(T) ~= length(E) | length(T) ~= length(Z)
     minLength= min([length(N) length(E) length(Z) length(T)]);
     N=N(1:minLength,1);
     E=E(1:minLength,1);
     Z=Z(1:minLength,1);
     T=T(1,1:minLength);
 end   
    
%----------------- Basic Parameters  ---------------
   
   % Magnitude
    Mag=sacst_z.mag;
 
    % Evt depth
    evdp = sacst_z.evdp;
        
    % Evt location
    evlo = sacst_z.evlo;
    evla = sacst_z.evla;
    
    % Stn location
    stlo = sacst_z.stlo;
    stla = sacst_z.stla;
    
    % Epicentral distance (degrees)
    gcarc = sacst_z.gcarc;  
    
    % Epicentral distance (km)
    dist = sacst_z.dist;
            
    % Azimuth
    az=sacst_z.az;
    
    % Back-azimuth   
    baz=sacst_z.baz;

%--------------- Rotations-------------------    
  % Rotation to ZRT coordinate system
    [R,TD]= rotation(N, E, Z,baz);
    

%------------ Data Processing: Resample, filter, scale ------------

    % Resample the data at dt_out= 0.01
   
    if (dt_in ~= dt_out)              %dt_out =0.01
        T_int = b_in:dt_out:e_in;

        Z = interp1(T,Z,T_int,'spline');
        R = interp1(T,R,T_int,'spline');
        TD = interp1(T,TD,T_int,'spline');
    end
    T=T_int;    %New Full time series
    
    t_shift = b_in-dt_out;
    t_start = dt_out;
    t_end = e_in-t_shift;
    T = t_start:dt_out:t_end;
   
    % Design a second order Butterworth band-pass filter           
    sample_fre=1/dt_out;
                
    low=lowpass/(sample_fre/2);
    high=highpass/(sample_fre/2);
    [b a] = butter(2,[high low], 'bandpass');
    
    Z_filtered=filter(b,a,Z);
    R_filtered=filter(b,a,R); 
    TD_filtered=filter(b,a,TD); 
    
    Z = Z_filtered;
    R = R_filtered;
    TD = TD_filtered;
    

%----------------------- Plotting ----------------------
% Just T component 
%      figure(k)
%      plot(T,TD,'k')
%      set(gcf,'Position',[0 0 1500 1000])
%      title(num2str(k))
%      hold on
    
%----------------------- Get arrival times ---------------

% velocities of Sn and Lg
vsn = 4.0;
vlg = 2.8;

vsn_max = 4.8;
vlg_max = 3.6;

if dist > 300
    vpn = 8.1;
    tsn_diff = dist*(1/vsn-1/vpn);
    tlg_diff = dist*(1/vlg-1/vpn);
    
    tsn_diff_min = dist*(1/vsn_max-1/vpn);
    tlg_diff_min = dist*(1/vlg_max-1/vpn);
    
elseif dist <300
    vp = 6.4;
    tsn_diff = dist*(1/vsn-1/vp);
    tlg_diff = dist*(1/vlg-1/vp);
    
    tsn_diff_min = dist*(1/vsn_max-1/vp);
    tlg_diff_min = dist*(1/vlg_max-1/vp);
end

% P arrival time
% [tp,amp] = ginput(1);

tp = 120;

% Sn and Lg windows
tsn = tsn_diff+tp;
tlg = tlg_diff+tp;

tsn_min = tsn_diff_min+tp;
tlg_min = tlg_diff_min+tp;

% top = max(abs(TD));
% btm = -top;
% hp=line([tp tp], [btm top]);
% set(hp,'LineWidth',2,'Color','b');

ntp = ceil(tp/dt_out);
ntsn = ceil(tsn/dt_out);
ntlg = ceil(tlg/dt_out);

ntsn_min = ceil(tsn_min/dt_out);
ntlg_min = ceil(tlg_min/dt_out);

% plot(T(ntsn_min:ntsn),TD(ntsn_min:ntsn),'r','LineWidth',1.5)
% hold on
% plot(T(ntlg_min:ntlg),TD(ntlg_min:ntlg),'c','LineWidth',1.5)

%-------Compare Sn and Lg amplitude
sn_amp = rms(TD(ntsn_min:ntsn));
lg_amp = rms(TD(ntlg_min:ntlg));

% Signal to noise ratio
ntn = ceil((tp-5)/dt_out);
ntn_min = ceil((tp-25)/dt_out);
% hold on
% plot(T(ntn_min:ntn),TD(ntn_min:ntn),'g','LineWidth',1.5)
noise = rms(TD(ntn_min:ntn));
SNRsn = sn_amp/noise;
SNRlg = lg_amp/noise;

if SNRsn <4 & SNRlg <4
    continue
end

% Sn/Lg amplitude ratio
ampr = sn_amp/lg_amp;

ampr

info =[dist,ntp,ntsn_min,ntsn,ntlg_min,ntlg,ntn_min,ntn]';

%----------------------- Write data---------------
K1_LF_data(1:length(TD),k) = TD';

fprintf(STN,'%f %f %f \n',[stlo ; stla; ampr]);
fprintf(INFO,'%f %u %u %u %u %u %u %u\n',info);

end


K1_LF_data( :, all(~K1_LF_data,1) ) = [];  % delete zero columns, due to not passing SNR conditions
fclose(STN); 
fclose(INFO); 

save K1_LF_data.mat
 


        
