function [ sacst ] = SACST_interp( sacst, ts_interp, varargin )
%interpolate data in SACST to given time samples
%--------------------------------------------------------------------------
%Syntax: 
% 
%   [ sacst_interp ] = SACST_interp( sacst, ts_interp )
%   [ sacst_interp ] = SACST_interp( sacst, ts_interp, 'PropertyName', PropertyValue )
%--------------------------------------------------------------------------
%Description:
% 
%   [ sacst_interp ] = SACST_interp( sacst, ts_interp ) interpolates data
%   in sacst at time points given by ts_interp;
%
%--------------------------------------------------------------------------
%PropertyName   |   PropertyValue       |   Description
%   
%   'ref'       | any time head filed   | set zero time in ts_interp to the
%       specified reference time given in the time marker
%   'rmnan'     |  0(default) or 1      | decide wheter to remove NaN caused by
%   interpolating out of range
%   
%List of the reference time markers for 'ref': 
%   - any time head filed in SACST(e.g. a, b, e, t0-t9, user0-9)
%   - 'gmt': zero time is set to 'Jan-1-0000 00:00:00', which is
%           used in Matlab buit-in 'datenum';
%   - '0': zero time is set to the relative zero time in each SACST (default)
%--------------------------------------------------------------------------
%History:
%
%   [Oct. 19, 2011]: created
%       1) check NaN in the output before you try to use imksac to create a new
%           sac file! this means you are trying to interpolate data out of
%           the time range of the input seismogram. (although a sac file can be 
%           created and read by SAC successfully, SAC can't generate a plot)
%   [Nov 11, 2011]: output is reversed to [ sachd_i, sacdat_i ]
%   [2011-12-16]: modified to read and output sac structure;
%   [2012-02-11]: modified to read in and output SACST;
%   [2012-02-22]: sacst.npts is checked to make sure the same length of
%   sacst.data
%--------------------------------------------------------------------------

%% Parse argument

p = inputParser;
p.addRequired('sacst', @isstruct);
p.addRequired('ts_interp', @isnumeric);
SACtmarker = {'0','gmt','b','e','o','a',...
    't0','t1','t2','t3','t4','t5','t6','t7','t8','t9',...
    'user0','user1','user2','user3','user4','user5','user6','user7','user8','user9'};
p.addParamValue('ref','0',@(x) any(strcmpi(x,SACtmarker)));
% p.addOptional('reftmarker','0',@(x) any(strcmpi(x,SACtmarker)));
p.addParamValue('rmnan',0,@(x) x==0 | x==1);
p.parse(sacst, ts_interp, varargin{:});

%
reftmarker = p.Results.ref;
is_rmnan = logical(p.Results.rmnan);
% if ~strcmpi('rmnan',p.Results.UsingDefaults)
%     is_rmnan = true;
% end
Nsac = numel(sacst);

% put ts_interp into a coulumn array
% ts_interp = reshape(ts_interp,[],1);

%% Time of the relative zero time in SAC from the Reference time
if strcmp(reftmarker,'gmt')
    t0_ref = gmt2sec(sacst);
elseif strcmp(reftmarker,'0')
    t0_ref = zeros(1,Nsac);
else
    t0_ref = - eval(['[sacst.',reftmarker,']']);
end

%% interpolate with Matlab buit-in: interp1

for i = 1:Nsac
    % get the time samples in the SAC record with respcet to the reference
    % time
    % make sure npts is right (added on 2012-02-22)
    sacst(i).npts = length(sacst(i).data);
    ts_rec = sacst(i).b + sacst(i).delta*(0:(sacst(i).npts-1))+t0_ref(i);
    % interp1
%     t_taper = 5*sacst(i).delta; % avoid error in using 'spline' for 'interp1'
%     ind_interp = find(ts_rec>min(ts_interp)-t_taper & ts_rec<max(ts_interp)+t_taper);
%     sacst(i).data =
%     interp1(ts_rec(ind_interp),sacst(i).data(ind_interp),ts_interp);
    sacst(i).data = interp1(ts_rec,sacst(i).data,ts_interp);
    % check for NaN
    ts_isac = reshape(ts_interp,[],1);
    if is_rmnan
        isnan_isac = isnan(sacst(i).data);
        ts_isac = ts_interp(~isnan_isac);
        sacst(i).data = sacst(i).data(~isnan_isac);
    end
    % modify SAC head fields
    sacst(i).b = min(ts_isac)-t0_ref(i);
    sacst(i).e = max(ts_isac)-t0_ref(i);
    sacst(i).npts = length(ts_isac);
    % check if ts_isac are equi-distant samples
    dt = diff(ts_isac);
    dt_mean = mean(dt);
    isequisample = max(abs((dt-dt_mean)/dt_mean))<10^-3;
    sacst(i).leven = isequisample;
    if isequisample
        sacst(i).delta = dt_mean;
    else
        sacst(i).delta = -12345;
    end
end

%% Nested functions

% gmt2sac: calculate the relative second counts of the reference time in SAC 
    function [ secnum ] = gmt2sec( sacst )
        % get date
        year = [sacst.nzyear];
        jday = [sacst.nzjday];
        hour = [sacst.nzjday];
        min = [sacst.nzmin];
        sec = [sacst.nzsec];
        msec = [sacst.nzmsec];
        % check for undefined date
        if any(year==-12345)
            ind = find(year == -12345);
            msgID = 'SACST_interp:gmt2sec:argChk';
            errmsg = 'GMT time is NOT set in SACST at index: %s';
            error(msgID,errmsg,num2str(ind));
        end
        % calculate the second counts
        secnum = (datenum(year,1,0)+jday)*86400+hour*3600+min*60+sec+msec*0.001;
    end

end
