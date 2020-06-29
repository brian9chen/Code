function [ tlag_x1 ] = alignSAC_corr(fn_sac1, fn_sac2, twin, dt, refmarker )
%ALIGNSAC_CORR align two seismograms within twin reference to refmarker
% created on Oct. 19, 2011
%--------------------------------------------------------------------------
% Usage: [ tlag ] = alignSAC_corr(fn_sac1, fn_sac2, twin, refmarker )
%--------------------------------------------------------------------------
% Notes:
%
% Oct. 19, 2011
%   1) the refmarker in fn_sac1 is moved to align with fn_sac2;
%   2) detrend and cos taper should not be used because they will introduce
%   distortion in the original signal, and a constant value does not affect
%   the relative value in the correlation result;

%%
%--------------------------------------------------------------------------
% read in sac file
%--------------------------------------------------------------------------
[hd1,dat1] = irdsac(fn_sac1);
[hd2,dat2] = irdsac(fn_sac2);
%--------------------------------------------------------------------------
% read dat in the given time window
%--------------------------------------------------------------------------
ts = (min(twin):dt:max(twin))';
% Nt = length(ts);
%
x1 = interpSAC_relative(hd1,dat1,ts,refmarker);
x2 = interpSAC_relative(hd2,dat2,ts,refmarker);
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

Nc12_half = fix(Nc12/2+1);

Nlag = (ind-1)*(ind<Nc12_half)+(ind-Nc12-1)*(ind>Nc12_half);

tlag_x1 = Nlag*dt;
%--------------------------------------------------------------------------
% write sac for x1 with aligned refmarker
%--------------------------------------------------------------------------
useless = evalc(['hd1.',refmarker,' = hd1.',refmarker,'+tlag_x1']);
imksac(hd1,dat1,fn_sac1);
end

