function [ sachd_i, sacdat_i ] = interpSAC_relative( sachd, sacdat, ref_tmarker, ts_i )
%INTERPSAC interpolates sacfile onto given time samples ts_i
% created on Oct. 19, 2011
%--------------------------------------------------------------------------
% Usage: [ sachd_i, sacdat_i ] = interpSAC_relative( sacsachd, sacdat, ts_i, ref_tmarker )
%--------------------------------------------------------------------------
% Inputs:
%   sacsachd: sac header structure;
%   sacdat: sac data array;
%   ts_i: vector of interpolation time samples (relative to ref_tmaker)
%   ref_tmaker: the time marker in SAC header for reference zero time;    
%--------------------------------------------------------------------------
% Outputs:
%	sacdat_i: interpolated sac data on to ts_i;
%	sacsachd_i: sac header structure;
%--------------------------------------------------------------------------
% Notes:
%
% Oct. 19, 2011
%   1) check NaN in the output before you try to use imksac to create a new
%   sac file! this means you are trying to interpolate data out of the time
%   range of the input seismogram. (although a sac file can be created and read by SAC successfully, SAC can't generate a plot)
% Nov 11, 2011: output is reversed to [ sachd_i, sacdat_i ]

%%
% Nsec_1day = 3600*24;
% Nsec_1hour = 3600;
% Nsec_1min = 60;

% t_ref = (datenum(sachd.nzyear,1,0)+sachd.nzjday)*Nsec_1day...
%         +sachd.nzhour*Nsec_1hour...
%         +sachd.nzmin*Nsec_1min...
%         +sachd.nzsec...
%         +sachd.nzmsec/1000;
%--------------------------------------------------------------------------
t_ref = eval(['sachd.',ref_tmarker]);
t_b = sachd.b;
ts = t_b + sachd.delta*(0:(sachd.npts-1));
%--------------------------------------------------------------------------
t_taper = 5*sachd.delta;
ind_ts_i = find(ts>min(ts_i+t_ref)-t_taper & ts<max(ts_i+t_ref)+t_taper);
%
sacdat_i = interp1(ts(ind_ts_i),sacdat(ind_ts_i,:),ts_i+t_ref);
%--------------------------------------------------------------------------
% modify sac header structure for the interpolated data series
sachd_i = sachd;
sachd_i.b = min(ts_i)+t_ref;
sachd_i.e = max(ts_i)+t_ref;
sachd_i.npts = length(ts_i);
dt_i = diff(ts_i);
sachd_i.leven = max(abs(diff(dt_i)))<10^-5;
if sachd_i.leven
    sachd_i.delta = dt_i(1);
else
    sachd_i.delta = -12345;
end
end
