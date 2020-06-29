function [ sac_st_i ] = SAC_interpolate( sac_st, ref_tmarker, ts_i )
% interpSAC interpolates sacfile onto given time samples ts_i
%--------------------------------------------------------------------------
% Usage: [ sac_st_i ] = SAC_interpolate( sac_st, ref_tmarker, ts_i )
%--------------------------------------------------------------------------
% Inputs:
%   sac_st: sac structure;
%   ref_tmaker: the time marker in SAC header for reference zero time;  
%   ts_i: vector of interpolation time samples (relative to ref_tmaker)
%--------------------------------------------------------------------------
% Outputs:
%	sac_st_i:  sac structure after data interpolation;
%--------------------------------------------------------------------------
% Notes:
%
% Oct. 19, 2011: created
%   1) check NaN in the output before you try to use imksac to create a new
%       sac file! this means you are trying to interpolate data out of the time
%       range of the input seismogram. (although a sac file can be created and read by SAC successfully, SAC can't generate a plot)
% Nov 11, 2011: output is reversed to [ sachd_i, sacdat_i ]
% 2011-12-16: modified to read and output sac structure;
%--------------------------------------------------------------------------

%%
% Nsec_1day = 3600*24;
% Nsec_1hour = 3600;
% Nsec_1min = 60;

% t_ref = (datenum(sac_st.nzyear,1,0)+sac_st.nzjday)*Nsec_1day...
%         +sac_st.nzhour*Nsec_1hour...
%         +sac_st.nzmin*Nsec_1min...
%         +sac_st.nzsec...
%         +sac_st.nzmsec/1000;
%--------------------------------------------------------------------------
if strcmp(ref_tmarker,'gmt')
    t_ref = 0;
    ts_i = ts_i - SAC_gmt2sec(sac_st);
elseif strcmp(ref_tmarker,'0')
    t_ref = 0;
else
    t_ref = eval(['sac_st.',ref_tmarker]);
end
% t_ref = eval(['sac_st.',ref_tmarker]);
t_b = sac_st.b;
ts = t_b + sac_st.delta*(0:(sac_st.npts-1));
%--------------------------------------------------------------------------
t_taper = 5*sac_st.delta;
ind_ts_i = find(ts>min(ts_i+t_ref)-t_taper & ts<max(ts_i+t_ref)+t_taper);
%
sacdat_i = interp1(ts(ind_ts_i),sac_st.data(ind_ts_i,:),ts_i+t_ref);
%--------------------------------------------------------------------------
% modify sac header structure for the interpolated data series
sac_st_i = sac_st;
sac_st_i.b = min(ts_i)+t_ref;
sac_st_i.e = max(ts_i)+t_ref;
sac_st_i.npts = length(ts_i);
dt_i = diff(ts_i);
dt_i_mean = mean(dt_i);
sac_st_i.leven = max(abs((dt_i-dt_i_mean)/dt_i_mean))<10^-5;
if sac_st_i.leven
    sac_st_i.delta = dt_i_mean;
else
    sac_st_i.delta = -12345;
end
sac_st_i.data = sacdat_i;
end
