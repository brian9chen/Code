function [ sacst_xcorr ] = SACST_Xcorr( varargin )
%calculate cross-correlation
%--------------------------------------------------------------------------
%Syntax:
%
%   sacst_xcorr = SACST_Xcorr( 'PropertyName', PropertyValue )
%--------------------------------------------------------------------------
%Description:
%   sacst_xcorr = SACST_Xcorr( 'PropertyName', PropertyValue )
%   calculates cross-correlation from SACST given in the parameters (see below 'PropertyName')
%--------------------------------------------------------------------------
%PropertyName   | PropertyValue |  Description
%
%   'src'       | type: SACST   | SACST of source
%   'rec'       | type: SACST   | SACST of record
%   'ref_src'   | '0'           | reference time marker for time cut
%   'ref_rec'   | '0'           | reference time marker for time cut
%   'twin_src'  | [-5 100]      | source time window
%   'twin_rec'  | [-5 100]      | record time window
%--------------------------------------------------------------------------
%Notes:
%
% 1) In freqeuncy domain: xcorr(t) = Integrate[rec(t')*src(t'-t),t'];
%       t is the delay time of src relative to rec;
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
% p.addParamValue('waterlevel',0.05,@(x) isnumeric(x) & x>0);
% p.addParamValue('gausswidth',2.5,@(x) isnumeric(x) & x>0);
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
% waterlevel = p.Results.waterlevel;
% gausswidth = p.Results.gausswidth;
is_onesrc = logical(p.Results.onesrc);

% consistency check
msgID = 'SACST_Xcorr:argChk';
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
sacst_xcorr = SACST_new(size_rec);
%
for idx_rec = 1:N_rec
    try 
        if is_onesrc
            sacst_xcorr(idx_rec) = xcorrSAC(sacst_src,sacst_rec(idx_rec),...
                ref_src,ref_rec,twin_src,twin_rec);
        else
            sacst_xcorr(idx_rec) = xcorrSAC(sacst_src(idx_rec),sacst_rec(idx_rec),...
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
function sacst1_xcorr = xcorrSAC(sacst1_src,sacst1_rec,ref_src,ref_rec,twin_src,twin_rec)

% time window cut and interpolate data to the same time samples
dt = min(sacst1_src.delta,sacst1_rec.delta);

ts_src = (min(twin_src):dt:max(twin_src))';
ts_rec = (min(twin_rec):dt:max(twin_rec))';

sacst1_src_cut = SACST_interp(sacst1_src,ts_src,'ref',ref_src,'rmnan',1);
sacst1_rec_cut = SACST_interp(sacst1_rec,ts_rec,'ref',ref_rec,'rmnan',1);

% Discrete Fourier Transform
Ns = sacst1_src_cut.npts;
Nr = sacst1_rec_cut.npts;

x_src = sacst1_src_cut.data;
x_rec = sacst1_rec_cut.data;

% padd zeros
% indsrc = ts_src>=0;
% indrec = ts_rec>=0;
% x_src = [x_src(indsrc);zeros(Npts_rec-1,1);x_src(~indsrc)];
% x_rec = [x_rec(indrec);zeros(Npts_src-1,1);x_rec(~indrec)];
Nt = Nr+Ns-1;
x_src = [x_src;zeros(Nr-1,1)];
x_rec = [x_rec;zeros(Ns-1,1)];

% spectrum
Fx_src = fft(x_src);
Fx_rec = fft(x_rec);

% Water-level division: pre-whittening and amplitude 
Fx_xcorr = Fx_rec.*conj(Fx_src);

% Inverse DFT
c = ifft(Fx_xcorr,'symmetric');

% time samples
% Nt = length(x_src)+length(x_rec)-1;
% ts_xcorr = [br-bs+(0:Nr-1)*dt, er-bs-dt*Nt+(1:Ns-1)*dt];
br = min(ts_rec);
bs = min(ts_src); es = max(ts_src);
tc = [br-bs+(0:Nr-1)*dt, br-es+(0:Ns-2)*dt];

% sort time samples
[tc,IX] = sort(tc);
c = c(IX);

%write out SACST
sacst1_xcorr = sacst1_src;

sacst1_xcorr.delta = dt;

% ref_time =
% SACST_gmt2sec(sacst1_rec,ref_rec)-SACST_gmt2sec(sacst1_rec,'0');
% sacst1_xcorr.b = min(tc)+ref_time;
% sacst1_xcorr.e = max(tc)+ref_time;
sacst1_xcorr.b = min(tc);
sacst1_xcorr.e = max(tc);
sacst1_xcorr.npts = Nt;

% kcmpnm = [sacst1_rec.kcmpnm,'/',sacst1_src.kcmpnm];
kcmpnm = 'xcorr';
sacst1_xcorr.kcmpnm = kcmpnm(kcmpnm~=0 & kcmpnm~=32); % trim all blanks off
sacst1_xcorr.cmpaz = -12345;
sacst1_xcorr.cmpinc = -12345;
%
sacst1_xcorr.data = c;
end

end