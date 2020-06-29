% make receiver functions
% [2012-02-28]: created

clear all;close all;clc
%% parameters

dir_event = 'event/';
fn_RFlst = 'event/event.lst';

dir_RF = 'RF/';

waterlevel = 0.05;
gausswidth = 2.5;

ref = '0';
twin_src = [-10,100];
twin_rec = [-10,100];

%% Load sac files

sacst_R = SACST_fread('list',fn_RFlst,'prefix',dir_event,'suffix','.BHR');
sacst_Z = SACST_fread('list',fn_RFlst,'prefix',dir_event,'suffix','.BHZ');

%% deconvolution

sacst_RZ = SACST_FDdeconv('src',sacst_Z,'rec',sacst_R,...
    'ref_src',ref,'ref_rec',ref,'twin_src',twin_src,'twin_rec',twin_rec,...
    'gausswidth',gausswidth,'waterlevel',waterlevel);

sacst_ZZ = SACST_FDdeconv('src',sacst_Z,'rec',sacst_Z,...
    'ref_src',ref,'ref_rec',ref,'twin_src',twin_src,'twin_rec',twin_rec,...
    'gausswidth',gausswidth,'waterlevel',waterlevel);

%% Normalize amplitude

for isac = 1:length(sacst_RZ)
    ampZ = max(sacst_ZZ(isac).data);
    sacst_RZ(isac).data = sacst_RZ(isac).data/ampZ;
end

%% write out sac

SACST_fwrite(sacst_RZ,'list',fn_RFlst,'prefix',dir_RF,'suffix','.RZ')
SACST_fwrite(sacst_ZZ,'list',fn_RFlst,'prefix',dir_RF,'suffix','.ZZ')
