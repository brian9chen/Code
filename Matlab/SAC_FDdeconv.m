function [ sac_st_quot ] = SAC_FDdeconv( sac_st_denom, sac_st_numer, ref_tmarker, twin_denom, twin_numer, waterlevel, gausswidth )
%--------------------------------------------------------------------------
%SAC_FDdeconv: Frequency domain deconvolution using pre-whitenning 
%--------------------------------------------------------------------------
%Usage: [ sac_st_quot ] = SAC_FDdeconv( sac_st_denom, sac_st_numer, ref_tmarker, twin, waterlevel, gausswidth )
%--------------------------------------------------------------------------
%Inputs:
%   sac_st_denom: sac structure of the denominator;
%   sac_st_numer: sac structure of the numerator;
%   ref_tmarker: time marker in sac head for reference zero time;
%   twin_denom: time window for denominator;
%   twin_numer: time window for numerator;
%   waterlevel: water level for normalization;
%   gausswidth: half width of the gaussian low-pass filter;
%--------------------------------------------------------------------------
%Output:
%   sac_st_quot: sac structure of the quotient
%--------------------------------------------------------------------------
%Note:
% 1) In freqeuncy domain, Quotient = (1+c/mean(Denominator^2))
%   Numerator*Conj(Denominator)/(Denominator^2+c),
%	where c = waterlevel*max(Denominator^2), and (1+c/mean(Denominator^2)) is the 
%	coefficient to compensate for the amplitude loss due to the water level;
% 2) Before inverse Fourier transform, Quotient is further multiplied by
%   GaussWeight = exp(-w^2/4/gausswidth^2);
%
% Reference: lecture notes by Lev Vinik, Receiver function techniques
%--------------------------------------------------------------------------
%History:
%   [2011-12-16]: created
%   [2011-12-18]: modified, add twin_denom and twin_numer
%	[2012-01-16]
%		- modified, using pre-whittening term in stead of water-level cutoff
%--------------------------------------------------------------------------

%% time window cut and interpolate data

dt = min(sac_st_denom.delta,sac_st_numer.delta);

ts_denom = (min(twin_denom):dt:max(twin_denom))';
ts_numer = (min(twin_numer):dt:max(twin_numer))';

sac_st_denom_cut = SAC_interpolate(sac_st_denom,ref_tmarker,ts_denom);
sac_st_numer_cut = SAC_interpolate(sac_st_numer,ref_tmarker,ts_numer);

%% Discrete Fourier Transform

Ndenom = sac_st_denom_cut.npts;
Nnumer = sac_st_numer_cut.npts;

denom = sac_st_denom_cut.data;
numer = sac_st_numer_cut.data;

% spectrum
F_numer = fft([numer;zeros(Ndenom-1,1)]);
F_denom = fft([denom;zeros(Nnumer-1,1)]);

% angular freqency sample points
Npts = length(F_numer);
dw = 2*pi/Npts/dt;
N_half = (Npts-2+mod(Npts,2))/2;
w = dw*[0:N_half,pi/dt*ones(1-mod(Npts,2),1),-N_half:1:-1]';

% power spectrum of numerator
F2_denom = abs(F_denom).^2;

%% Water-level division

% pre-whittening coefficient 
F2_wl = waterlevel*max(F2_denom);

% Gaussian low-pass filter
gaussfilter = exp(-w.^2/4/gausswidth);

% Water-level division
F_quot = (1+F2_wl/mean(F2_denom))*F_numer.*conj(F_denom)./(F2_denom+F2_wl);
F_quot = F_quot.*gaussfilter;

%% Inverse DFT

quot = ifft(F_quot,'symmetric');

t0_denom = eval(['sac_st_denom_cut.',ref_tmarker]);
t0_numer = eval(['sac_st_numer_cut.',ref_tmarker]);

tb_denom = sac_st_denom_cut.b;
tb_numer = sac_st_numer_cut.b;

te_denom = sac_st_denom_cut.e;
% te_numer = sac_st_denom_cut.e;

tlag_pos = (t0_denom-tb_denom)-(t0_numer-tb_numer);
tlag_neg = -((te_denom-t0_denom)+(t0_numer-tb_numer));

ts_quot = [tlag_pos+dt*(0:Nnumer-1),tlag_neg+dt*(0:Ndenom-2)];

% ts_quot = dt*[0:N_half,pi/dt*ones(1-mod(Npts,2),1),-N_half:1:-1]';

[ts_quot,IX] = sort(ts_quot);

% ind_negative = ts_quot<0;
% ind_nonneg = logical(1-ind_negative);

quot = quot(IX);
% quot = [quot(ind_negative);quot(ind_nonneg)];

%% write sac structure

sac_st_quot = sac_st_numer;

sac_st_quot.data = quot;

sac_st_quot.kcmpnm = 'white';
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
