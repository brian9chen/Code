function [ sacst_deconv ] = SACST_FDdeconv( varargin )
%Deconvolution in frequency domain with pre-whitenning regularization 
%--------------------------------------------------------------------------
%Syntax:
%
%   sacst_deconv = SACST_FDdeconv( 'PropertyName', PropertyValue )
%--------------------------------------------------------------------------
%Description:
%
%   sacst_deconv = SACST_FDdeconv( 'PropertyName', PropertyValue )
%   calculates deconvolution from SACST given in the parameters (see below 'PropertyName')
%--------------------------------------------------------------------------
%PropertyName   | PropertyValue |  Description
%
%   'src'       | type: SACST   | SACST of source
%   'rec'       | type: SACST   | SACST of record
%   'ref_src'   | '0'           | reference time marker for time cut
%   'ref_rec'   | '0'           | reference time marker for time cut
%   'twin_src'  | [-5 100]      | source time window
%   'twin_rec'  | [-5 100]      | record time window
%   'waterlevel'| 0.05          | water-level 
%   'gausswidth'| 2.5           | frequency band width of Gaussian filter
%--------------------------------------------------------------------------
%Notes:
%
% 1) In freqeuncy domain, Quotient =
%   Numerator*Conj(Denominator)/max(Denominator^2,waterlevel*max(Denominator^2));
% 2) Before inverse Fourier transform, Quotient is multiplied by
%   GaussWeight = exp(-w^2/4/gausswidth^2);
%
% Reference: lecture notes by Lev Vinik, Receiver function techniques
%--------------------------------------------------------------------------
%History:
%
%   [2011-12-16]: created
%   [2011-12-18]: modified, add twin_denom and twin_numer
%   [2012-02-19]: modified, add help and use new SACST as input and output
%   [2012-02-22]: isnumeric is used instead of isscalar, because isscalar
%   can't tell the difference between a number and a single char.
%--------------------------------------------------------------------------

%% Parse and check parameters

% define the object: inputParser
p = inputParser;

% get parameters
p.addParamValue('src',[],@isstruct);
p.addParamValue('rec',[],@isstruct);
p.addParamValue('ref_src','0',@ischar);
p.addParamValue('ref_rec','0',@ischar);
p.addParamValue('twin_src',[-5 100],@(x) isvector(x) & length(x)==2);
p.addParamValue('twin_rec',[-5 100],@(x) isvector(x) & length(x)==2);
p.addParamValue('waterlevel',0.05,@(x) isnumeric(x) & x>0);
p.addParamValue('gausswidth',2.5,@(x) isnumeric(x) & x>0);
p.addParamValue('onesrc',false,@(x) isscalar(x));
% p.KeepUnmatched = true;

% parsing arguments
p.parse(varargin{:});

% set parameters
sacst_src = p.Results.src;
sacst_rec = p.Results.rec;
ref_src = p.Results.ref_src;
ref_rec = p.Results.ref_rec;
twin_src = p.Results.twin_src;
twin_rec = p.Results.twin_rec;
waterlevel = p.Results.waterlevel;
gausswidth = p.Results.gausswidth;
is_onesrc = logical(p.Results.onesrc);

% consistency check
msgID = 'SACST_FDdeconv:argChk';
size_src = size(sacst_src);
size_rec = size(sacst_rec);
N_src = numel(sacst_src);
N_rec = numel(sacst_rec);
if is_onesrc
    if N_src ~= 1
        errmsg = 'One source is used while numel(src) = %d !';
        error(msgID,errmsg,N_src);
    end
    disp 'Using one source file for multiple records!'
elseif size_src ~= size_rec
    errmsg = 'sacst_src and sacst_rec should have the same dimensions!';
    error(msgID,errmsg);
end

%% Deconvolution loop
% initialize
sacst_deconv = SACST_new(size_rec);
%
for idx_rec = 1:N_rec
    try 
        if is_onesrc
            sacst_deconv(idx_rec) = deconvSAC(sacst_src,sacst_rec(idx_rec),...
                ref_src,ref_rec,twin_src,twin_rec);
        else
            sacst_deconv(idx_rec) = deconvSAC(sacst_src(idx_rec),sacst_rec(idx_rec),...
                ref_src,ref_rec,twin_src,twin_rec);
        end
    catch errmsg
        disp ====================================
        fprintf('Error at index: %d\n',idx_rec)
        disp ====================================
        fprintf('\n%s\n',errmsg.getReport)
    end
end

%% Nested function

% deconvolution from a single rec and src pair
function sacst1_deconv = deconvSAC(sacst1_src,sacst1_rec,ref_src,ref_rec,twin_src,twin_rec)

% time window cut and interpolate data to the same time samples
dt = min(sacst1_src.delta,sacst1_rec.delta);

ts_src = (min(twin_src):dt:max(twin_src))';
ts_rec = (min(twin_rec):dt:max(twin_rec))';

sacst1_src_cut = SACST_interp(sacst1_src,ts_src,'ref',ref_src,'rmnan',1);
sacst1_rec_cut = SACST_interp(sacst1_rec,ts_rec,'ref',ref_rec,'rmnan',1);

% Discrete Fourier Transform
Npts_src = sacst1_src_cut.npts;
Npts_rec = sacst1_rec_cut.npts;

x_src = sacst1_src_cut.data;
x_rec = sacst1_rec_cut.data;

% padd zeros
Npts = length(x_src)+length(x_rec);
Npts = Npts-1+mod(Npts,2);

% spectrum
Fx_rec = fft([x_rec;zeros(Npts-Npts_rec,1)]);
Fx_src = fft([x_src;zeros(Npts-Npts_src,1)]);

% angular freqency sample points
dw = 2*pi/Npts/dt;
Npts_half = (Npts-1)/2;
w = dw*[0:Npts_half,-Npts_half:1:-1]';

% power spectrum of source
F2x_src = abs(Fx_src).^2;

% Water-level division
F2_wl = waterlevel*max(F2x_src);

% Gaussian low-pass filter
gaussfilter = exp(-w.^2/4/gausswidth^2);

% Water-level division: pre-whittening and amplitude 
Fx_deconv = (1+F2_wl/mean(F2x_src))*Fx_rec.*conj(Fx_src)./(F2x_src+F2_wl);
Fx_deconv = Fx_deconv.*gaussfilter;

% Inverse DFT
x_deconv = ifft(Fx_deconv,'symmetric');

% time samples
ts_deconv = dt*[0:Npts_rec-1,-(Npts-Npts_rec):-1];
[ts_deconv,IX] = sort(ts_deconv);

x_deconv = x_deconv(IX);

%write out SACST
sacst1_deconv = sacst1_rec;

sacst1_deconv.data = x_deconv;

kcmpnm = [sacst1_rec.kcmpnm,'/',sacst1_src.kcmpnm];
sacst1_deconv.kcmpnm = kcmpnm(kcmpnm~=0 & kcmpnm~=32); % trim all blanks off
sacst1_deconv.cmpaz = -12345;
sacst1_deconv.cmpinc = -12345;
%
ref_time = SACST_gmt2sec(sacst1_rec,ref_rec)-SACST_gmt2sec(sacst1_rec,'0');
%
sacst1_deconv.b = min(ts_deconv)+ref_time;
sacst1_deconv.e = max(ts_deconv)+ref_time;
sacst1_deconv.npts = length(x_deconv);
%
sacst1_deconv.delta = dt;
end

end
