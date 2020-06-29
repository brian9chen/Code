% test alginSAC_corr
% created on Oct. 19, 2011
% Notes:
% 
% Oct. 19, 2011
%   1) IF: the original displacement is large
%      THEN: a) iteration is needed to make best-matching
%            b) time window should be large at first then decrease as the
%            time lag decreases.
%           
%%
clear all;close all;clc
%--------------------------------------------------------------------------
% parameter
%--------------------------------------------------------------------------
fn_sac1 = 'NE6C.sac';
fn_sac2 = 'NE4B.sac';
%
dt = 0.01;
twin = [-5,10];
refmarker = 't1';
%
ts = twin(1):dt:twin(2);
%--------------------------------------------------------------------------
% align sac file
%--------------------------------------------------------------------------
[ tlag_x1 ] = alignSAC_corr(fn_sac1, fn_sac2, twin, dt, refmarker );
%--------------------------------------------------------------------------
% plot new sac file
%--------------------------------------------------------------------------
[hd1,dat1] = irdsac(fn_sac1);
[hd2,dat2] = irdsac(fn_sac2);
x1 = interpSAC_relative(hd1,dat1,ts,refmarker);
x2 = interpSAC_relative(hd2,dat2,ts,refmarker);
%
figure('name','plot aligned data')
hold on
plot(ts,x1,ts,x2)
plot([0 0],ylim(gca))
grid on
legend('x1','x2')