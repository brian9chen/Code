function [ hd1_align, tlag_x1, maxcc ] = alignSAC_corr(hd1, dat1, hd2, dat2, ref_tmarker, twin, dt)
% alignSAC_corr: align two seismograms within twin reference to ref_tmarker
%--------------------------------------------------------------------------
% Usage: [ tlag_x1, hd1_align ] = alignSAC_corr(hd1, dat1, hd2, dat2, twin, dt, refmarker )
%--------------------------------------------------------------------------
% Inputs:
%   hd1,dat1: head and data of sac1;
%   hd2,dat2: head and data of sac2;
%   ref_tmaker,twin,dt: time series used to re-sample sac data 
%--------------------------------------------------------------------------
% Outputs:
%   hd1_align: hd1 with ref_tmarker aligned
%   tlag_x1: time lag of sac1 relative to sac2;
%   maxcc: maximum correlation coefficient;
%--------------------------------------------------------------------------
% Notes:
%   Oct 19, 2011: created
%       1) the ref_tmarker in hd1 is moved to align with hd2;
%       2) detrend and cosine taper should not be used because they will introduce
%       distortion in the original signal, and a constant value does not affect
%       the relative value in the correlation result;
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
% read dat in the given time window
%--------------------------------------------------------------------------
ts = (min(twin):dt:max(twin))';
% Nt = length(ts);
%
[hdx1,x1] = interpSAC_relative(hd1,dat1,ref_tmarker,ts);
[hdx2,x2] = interpSAC_relative(hd2,dat2,ref_tmarker,ts);
%--------------------------------------------------------------------------
% correlation
%--------------------------------------------------------------------------
% x_taper = tukeywin(Nt,0.1);
% x1 = detrend(x1).*x_taper;
% x2 = detrend(x2).*x_taper;
%
c12 = icorr(x1,x2);
Nc12 = length(c12);
%--------------------------------------------------------------------------
% get the lag time between x1 and x2
%--------------------------------------------------------------------------
[y,ind] = max(abs(c12));
maxcc = y/norm(x1)/norm(x2);

Nc12_half = fix(Nc12/2+1);

Nlag = (ind-1)*(ind<Nc12_half)+(ind-Nc12-1)*(ind>Nc12_half);

tlag_x1 = Nlag*dt;
%--------------------------------------------------------------------------
% write sac for x1 with aligned refmarker
%--------------------------------------------------------------------------
hd1_align = hd1;
eval(['hd1_align.',ref_tmarker,' = hd1.',ref_tmarker,'+tlag_x1;']);
% imksac(hd1,dat1,fn_sac1);
end

