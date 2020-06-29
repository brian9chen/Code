function [ sachd_i, sacdat_i ] = interpSAC_absolute( sachd, sacdat, ts_i )
%--------------------------------------------------------------------------
% interpSAC_absolute: interpolates sacfile onto given time samples ts_interp
%--------------------------------------------------------------------------
% Usage: [ sachd_i, sacdat_i ] = interpSAC_absolute( sachd, sacdat, ts_i )
%--------------------------------------------------------------------------
% Inputs:
%   sachd: sac header structure;
%   sacdat: sac data array;
% 	ts_i: time series for interpolation
%--------------------------------------------------------------------------
% Outputs:
%	sacdat_i: interpolated sac data on to ts_i;
%	sachd_i: sac header structure;
%--------------------------------------------------------------------------
% Notes:
%	Oct 6, 2011: created;
%   Nov 8, 2011: because SHD_gmt2sec is changed to receive a time marker, t_b is directly calculated;
%	Nov 8, 2011: SHD_gmt2sec is changed to gmt2sec_SHD
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
% absolute seconds of the beginning time 
% t_ref = yjd2sec(sachd.nzyear,sachd.nzjday,sachd.nzhour,sachd.nzmin,sachd.nzsec+sachd.nzmsec/1000);
gmt_o = gmt2sec_SHD(sachd,'o');
gmt_b = gmt2sec_SHD(sachd,'b');
% time of the first data sample
% t_b = t_ref+sachd.b;
% time series of all the data samples
ts = gmt_b + sachd.delta*(0:(sachd.npts-1));
% find indices of the data samples within the interpolating time range
t_taper = 5*sachd.delta;
ind_ts_i = find(ts>min(ts_i)-t_taper & ts<max(ts_i)+t_taper);
% interpolation using interp1 (linear)
sacdat_i = interp1(ts(ind_ts_i),sacdat(ind_ts_i),ts_i);
% modify sac header structure for the interpolated data series
sachd_i = sachd;
sachd_i.b = min(ts_i)-gmt_o;
sachd_i.e = max(ts_i)-gmt_o;
sachd_i.npts = length(ts_i);
dt_i = diff(ts_i);
sachd_i.leven = max(abs(diff(dt_i)))<10^-5;
if sachd_i.leven
    sachd_i.delta = dt_i(1);
else
    sachd_i.delta = -12345;
end
end
