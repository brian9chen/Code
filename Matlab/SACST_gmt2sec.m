function [ secnum ] = SACST_gmt2sec( sacst, varargin )
%--------------------------------------------------------------------------
% SAC_gmt2sec: calculates the total number of seconds of the time marker in sac header
%--------------------------------------------------------------------------
% Usage: [ secondnum ] = SAC_gmt2sec( sac_st, tmarker )
%--------------------------------------------------------------------------
% Inputs:
%   sac_st: a structure of sac header;
%   tmarker: time marker to calculate the absolute seconds
%--------------------------------------------------------------------------
% Outputs:
%   secondnum: number of seconds
%--------------------------------------------------------------------------
% Notes:
%   Nov 8, 2011: created;
%   2011-12-16: modified, add time marker for 'gmt';
%   [2012-02-20] modified, if GMT not set, use 2000-001_00:00:00
%--------------------------------------------------------------------------

%% Parse argument
p = inputParser;
p.addRequired('sacst', @isstruct);
SACtmarker = {'0','gmt','b','e','o','a',...
    't0','t1','t2','t3','t4','t5','t6','t7','t8','t9',...
    'user0','user1','user2','user3','user4','user5','user6','user7','user8','user9'};
p.addOptional('reftmarker','gmt',@(x) any(strcmpi(x,SACtmarker)));
p.parse(sacst,varargin{:});

reftmarker = p.Results.reftmarker;

Nsac = length(sacst);
%% Calculate the second counts
% get date
year = [sacst.nzyear];
jday = [sacst.nzjday];
hour = [sacst.nzjday];
min = [sacst.nzmin];
sec = [sacst.nzsec];
msec = [sacst.nzmsec];
% t_ref = eval(['[sacst.',reftmarker,']']);

% check for undefined date
if any(year==-12345)
    ind = find(year == -12345);
    msgID = 'SACST_interp:gmt2sec:argChk';
    warnmsg = 'GMT time is NOT set in SACST at index: %s \n Use default 2000-001_00:00:00';
    warning(msgID,warnmsg,num2str(ind));
    year(ind) = 2000; jday(ind) = 1; hour(ind) = 0; min(ind) = 0; sec(ind) = 0; msec(ind) = 0;
end

% relative time of the reference time marker
if any(strcmpi(reftmarker,{'gmt','0'}))
    t_ref = zeros(Nsac,1);
else
    t_ref = eval(['[sacst.',reftmarker,']']);
end

% calculate the second counts
secnum = (datenum(year,1,0)+jday)*86400+hour*3600+min*60+sec+msec*0.001+t_ref;

end