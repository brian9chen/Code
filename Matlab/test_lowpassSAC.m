% test lowpassSAC
% created on Oct. 15, 2011

%%
clear all;close all;clc
%--------------------------------------------------------------------------
% parameter
%--------------------------------------------------------------------------
sacdir = '/home/taokai/Documents/MyNoteBook/files/SeismicImaging/NECESSArray/Sync88/sac';
% sacdir = '../ModalDecomposition/sac/';
lstdir = '../list';
%
evnm = '2009.272.17.48.10.99';
stnm = 'NE59';
% stla = 44.09594;
% stlo = 125.96106;
cmpnm = 'BHZ';
%--------------------------------------------------------------------------
% read sac
%--------------------------------------------------------------------------
fn_sac = fullfile(sacdir,evnm,[stnm,'.',evnm,'.',cmpnm,'.sac']);
%
[hd,dat] = irdsac(fn_sac);
%--------------------------------------------------------------------------
% lowpass filter
%--------------------------------------------------------------------------
% filter parameters
Fpass = 2;
Fstop = 4;
Apass = 1;
Astop = 60;
Fs = 1/hd.delta;
%
filter_para = fdesign.lowpass(Fpass,Fstop,Apass,Astop,Fs);
% design filter
filter_lp = design(filter_para,'equiripple');
% lowpass 
[ dat_lp, hd_lp ] = lowpassSAC( hd, dat, filter_lp );
%--------------------------------------------------------------------------
% plot
%--------------------------------------------------------------------------
ts = hd.delta*(0:hd.npts-1);
figure('name','dat and lowpass filtered dat')
plot(ts,dat,ts+hd_lp.b-hd.b,dat_lp)
legend('origin','lowpass')
grid on