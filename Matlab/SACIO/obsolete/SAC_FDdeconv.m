function [ sac_st_quot ] = SAC_FDdeconv( sac_st_denom, sac_st_numer, ref_tmarker, twin, waterlevel, gausswidth )
%--------------------------------------------------------------------------
% SAC_FDdeconv: Frequency domain deconvolution
%--------------------------------------------------------------------------
% Usage: [ sac_st_quot ] = SAC_FDdeconv( sac_st_denom, sac_st_numer, ret_tmarker, twin, waterlevel, gausswidth )
%--------------------------------------------------------------------------
% Input
%   sac_st_denom: sac structure of the denominator;
%   sac_st_numer: sac structure of the numerator;
%   ref_tmarker, twin: specified time window between ref_time + twin;
%   waterlevel: water level for normalization;
%   gausswidth: half width of the gaussian low-pass filter
%--------------------------------------------------------------------------
% Output:
%   sac_st_quot: sac structure of the quotient
%  
% In freqeuncy domain, Quotient =
%   Numerator*Conj(Denominator)/max(Denominator^2,waterlevel*max(Denominator^2));
% Before inverse Fourier transform, Quotient is further multiplied by
%   GaussWeight = exp(-w^2/4/gausswidth^2);
%
% Reference: lecture notes by Lev Vinik, Receiver function techniques
%--------------------------------------------------------------------------
% Note:
%   2011-12-16: created
%--------------------------------------------------------------------------

%% time window

dt = min(sac_st_denom.delta,sac_st_numer.delta);
ts_i = (min(twin):dt:max(twin))';

sac_st_denom_cut = SAC_interpolate(sac_st_denom,ref_tmarker,ts_i);
sac_st_numer_cut = SAC_interpolate(sac_st_numer,ref_tmarker,ts_i);

%% Discrete Fourier Transform

Npts = sac_st_denom_cut.npts;
denom = sac_st_denom_cut.data;
numer = sac_st_numer_cut.data;

% spectrum
F_numer = fft([numer;zeros(Npts-1,1)]);
F_denom = fft([denom;zeros(Npts-1,1)]);

% angular freqency sample points
Npts = length(F_numer);
dw = 2*pi/Npts/dt;
N_half = (Npts-2+mod(Npts,2))/2;
w = dw*[0:N_half,pi/dt*ones(1-mod(Npts,2),1),-N_half:1:-1]';

% power spectrum of numerator
F2_denom = abs(F_denom).^2;

%% Water-level division

% waterlevel
F2_wl = waterlevel*max(F2_denom);

% Gaussian low-pass filter
gaussfilter = exp(-w.^2/4/gausswidth);

% Water-level division
F_quot = F_numer.*conj(F_denom)./max(F2_wl*ones(size(F_denom)),F2_denom);
F_quot = F_quot.*gaussfilter;

%% Inverse DFT

quot = ifft(F_quot,'symmetric');

ts_quot = dt*[0:N_half,pi/dt*ones(1-mod(Npts,2),1),-N_half:1:-1]';

ind_negative = ts_quot<0;
ind_nonneg = logical(1-ind_negative);
quot = [quot(ind_negative);quot(ind_nonneg)];

%% write sac structure

sac_st_quot = sac_st_numer;

sac_st_quot.data = quot;

sac_st_quot.kcmpnm = 'quot';
sac_st_quot.cmpaz = -12345;
sac_st_quot.cmpinc = -12345;

% str_command = ['sac_st_quot.',ref_tmarker,' = sac_st_numer.',ref_tmarker,';'];
% eval(str_command);

str_command = ['sac_st_numer.',ref_tmarker];
ref_time = eval(str_command);

sac_st_quot.b = min(ts_quot)+ref_time;
sac_st_quot.e = max(ts_quot)+ref_time;
sac_st_quot.npts = length(quot);

sac_st_quot.delta = dt;
end
