% plot teleseismic traces according to epidistances
% created on Oct. 14, 2011

% plot teleseismic traces according to epidistances
% created on Oct. 14, 2011

%%
close all;clear all;clc
%--------------------------------------------------------------------------
% parameter
%--------------------------------------------------------------------------
sacdir = '/home/taokai/Documents/MyNoteBook/files/SeismicImaging/NECESSArray/Sync88/sac';
% sacdir = '../ModalDecomposition/sac/';
lstdir = '../list';
stnlst = 'NEArray.STN.lst';
evtlst = '2009255-2011231.M7.jday.adist30_90.cat';
%
netwkla = 45.149423;
netwklo = 124.370564;
%
fn_velmod = fullfile(lstdir,'iasp91_3000km.vel');
R = 6371;
%
twin = [-30,200];
dt = 0.05;
ts = (min(twin):dt:max(twin))';
%
cmpnm = 'BHZ';
% evnm = '2009.272.17.48.10.99';
evnm = '2010.147.17.14.46.57';
%--------------------------------------------------------------------------
% design filter
%--------------------------------------------------------------------------
dt_record = 0.025;
filter_para = fdesign.lowpass(0.5,1,0.1,60,1/dt_record);
filter_lp = design(filter_para,'equiripple');
grpdelay = dt*(filter_lp.impzlength-1)/2;
%--------------------------------------------------------------------------
% read in event list
%--------------------------------------------------------------------------
fid = fopen(fullfile(lstdir,evtlst),'r');
evtinfo = textscan(fid,'%s %f %f %f %f %f %f %f %f');
fclose(fid);
%
evnm_lst = evtinfo{1};
evyear_lst = evtinfo{2};
evjday_lst = evtinfo{3};
evhour_lst = evtinfo{4};
evmin_lst = evtinfo{5};
evsec_lst = evtinfo{6};
evla_lst = evtinfo{7};
evlo_lst = evtinfo{8};
evdp_lst = evtinfo{9}; 
%--------------------------------------------------------------------------
% get event info for a given event
%--------------------------------------------------------------------------
ind_evt = strmatch(evnm,evnm_lst);
evyear = evyear_lst(ind_evt);
evjday = evjday_lst(ind_evt);
evhour = evhour_lst(ind_evt);
evmin = evmin_lst(ind_evt);
evsec = evsec_lst(ind_evt);
evla = evla_lst(ind_evt);
evlo = evlo_lst(ind_evt);
evdp = evdp_lst(ind_evt);
% calculate the P arrival time at the network center
velmod = load(fn_velmod);
adist = distaz(evla,evlo,netwkla,netwklo);
ttime = mktt4Pturn(evdp,0,adist,R,velmod);
%
t_P = yjd2sec(evyear,evjday,evhour,evmin,evsec)+ttime;
%--------------------------------------------------------------------------
% read in station list
%--------------------------------------------------------------------------
fid = fopen(fullfile(lstdir,stnlst),'r');
stninfo = textscan(fid,'%s %s %f %f %f');
fclose(fid);
%
stnm_lst = stninfo{2};
Nstn = length(stnm_lst);
%--------------------------------------------------------------------------
% read in data
%--------------------------------------------------------------------------
j = 0;
for i_stn = 1:Nstn
    % station name
    stnm = stnm_lst{i_stn};
    % read in sac file
    fn_sac = fullfile(sacdir,evnm,[stnm,'.',evnm,'.',cmpnm,'.sac']);
    % see if the sac file exists
    if ~exist(fn_sac,'file')
        fprintf('file not exist: %s\n',fn_sac);
        continue
    end
    % count number of sac files
    j = j+1;
    % read in sac file
    [hd, dat] = irdsac(fn_sac);
    % remove mean and trend
    dat_rt = detrend(dat);
    % lowpass filter
    [dat_lp,hd_lp] = lowpassSAC(hd,dat_rt,filter_lp);
    % interpolate sac
    [dat_i,hd_i] = interpSAC_absolute(hd_lp,dat_lp,ts+t_P);
    % trace matrix, one column per record
    trace_mat(:,j) = dat_i;
    % get epidistance
    adist_stn(j) = hd_i.gcarc;
end
%--------------------------------------------------------------------------
% plot trace
%--------------------------------------------------------------------------
Ntrace = length(adist_stn);
%
amp_trace = 3*max(abs(trace_mat));
str_title = ['normalized amplitude trace plot: ',evnm,' ',cmpnm];
figure('name',str_title)
hold on
for i = 1:Ntrace
    plot(ts+ttime,trace_mat(:,i)/amp_trace(i)+adist_stn(i));
end
xlabel('time: sec (zero: event time)')
ylabel('epidistance: deg')
title(str_title)
% view([90,90])
grid on
hold off