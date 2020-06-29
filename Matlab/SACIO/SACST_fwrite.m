function SACST_fwrite( sacst, varargin )
%writes sac files from SAC structure array 'sacst'
%--------------------------------------------------------------------------
%Syntax:
%
%   SACST_fwrite( sacst )
%   SACST_fwrite( sacst, sacname )
%   SACST_fwrite( sacst, ..., 'PropertyName', PropertyValue)
%--------------------------------------------------------------------------
%Description:
%
%   SACST_fwrite(sacst) writes SAC files from SAC struct SACST with
%   default names: kstnm.kcmpnm.sac
%
%   SACST_fwrite(sacst,sacname) writes out SAC files using names given in
%   the cell string 'sacname', if not enough names in 'sacname', then using
%   the default naming sheme.
%
%   SACST_fwrite( sacst, ..., 'PropertyName', PropertyValue)
%--------------------------------------------------------------------------
%PropertyName   | PropertyValue | Description
%
%   'list'      |   string      | output file name list
%   'prefix'    | []            | add to beginning of every sac file name
%   'suffix'    | []            | add to the end of every sac file name
%
% (e.g. fn_sac = [prefix, sacnm, suffix] will be used for output sac file
% path;)
% 
%--------------------------------------------------------------------------
%The SACST header fields are listed below:
%
%delta	stla	evla	data(10) iftype   dist     xminimum     trcLen	
%b      stlo	evlo	label(3) idep     az       xmaximum     scale
%e      stel	evel             iztype   baz      yminimum
%o      stdp	evdp             iinst    gcarc    ymaximum
%a      cmpaz	nzyear           istreg	  norid
%t0     cmpinc	nzjday           ievreg	  nevid
%t1     kstnm	nzhour           ievtyp	  nwfid
%t2     kcmpnm	nzmin            iqual	  nxsize
%t3     knetwk	nzsec            isynth	  nysize
%t4     kevnm   nzmsec     
%t5		
%t6		mag
%t7		imagtyp
%t8		imagsrc
%t9
%f
%k0
%ka
%kt1
%kt2
%kt3
%kt4
%kt5
%kt6
%kt7
%kt8
%kt9
%kf
% (response is a 10-element array, and trcLen is a scalar.)
%--------------------------------------------------------------------------
%Example:
%   
%   SACST_fwrite(sacst,{'sacnm1','sacnm2',...},'prefix','somedir/','suffix','.BHZ.sac' )
%--------------------------------------------------------------------------
%Note:
%   
%   1) 'list' will be ignored if 'sacnm' is defined, even if length(sacnm)
%   < length(sacst);
%--------------------------------------------------------------------------
%History:
%   
%   [2011-12-16] modified
%       - az, baz, gcarc, dist are NOT calculated based on evla,evlo,stla,stlo
%   [2012-02-19] modified
%       - add help, and parameter parser
%   [2012-02-28]: add parameter 'list'
%--------------------------------------------------------------------------


%% Parse and check parameters

% define the object: inputParser
p = inputParser;
% get parameters
p.addRequired('sacst',@isstruct)
p.addOptional('sacnm',{},@iscellstr)
p.addParamValue('list',[],@ischar);
p.addParamValue('prefix',[],@ischar);
p.addParamValue('suffix',[],@ischar);
% p.KeepUnmatched = true;
% parsing arguments
p.parse(sacst,varargin{:});

%
saclist = p.Results.list;
sacnm = p.Results.sacnm;
prefix = p.Results.prefix;
suffix = p.Results.suffix;

%
if any(strcmpi('sacnm',p.UsingDefaults)) && ~any(strcmpi('list',p.UsingDefaults))
    fid = fopen(saclist,'r');
    if fid == -1
        errID = 'SACST_fwrite:OpenList';
        errmsg = 'can not open list file: %s';
        warning(errID,errmsg,saclist)
    else
        sacnm = textscan(fid,'%s');
        sacnm = sacnm{1};
        fclose(fid);
    end
end
% check and define proper sac name
Nsac = numel(sacst);
Nsacnm = numel(sacnm);
if Nsacnm < Nsac
    Nadd = Nsac-Nsacnm;
    sacnm = [reshape(sacnm,1,[]),cell(1,Nadd)];
    for isac = (Nsacnm+1):Nsac
        kstnm = sacst(isac).kstnm;
        % remove all blanks or 0 char
        kstnm = kstnm(kstnm~=0 & kstnm~=32);
        if isempty(kstnm); kstnm = 'STN';end
        kcmpnm = sacst(isac).kcmpnm;
        kcmpnm = kcmpnm(kcmpnm~=0 & kcmpnm~=32);
        if isempty(kcmpnm); kcmpnm = num2str(isac);end
        %
        newsacnm = [kstnm,'.',kcmpnm,'.sac'];
        sacnm(isac) = {newsacnm};
    end
end

%% Check endianess of the computer
%    endian  = 'big'  big-endian byte order (e.g., UNIX)
%            = 'lil'  little-endian byte order (e.g., LINUX)
[computerType, maxSize, endian] = computer;

if strcmp(endian,'B')
    str_endian = 'ieee-be';
elseif strcmp(endian,'L')
    str_endian = 'ieee-le';
end

%% write out SAC files

for isac = 1:Nsac
    fn_sac1 = [prefix,sacnm{isac},suffix];
    try 
        wtSAC(sacst(isac),fn_sac1,str_endian);
    catch errmsg
%         disp(errmsg.MException)
        disp -------------------------------
        fprintf('Error in writing SAC file #%d: %s\n',isac,fn_sac1)
        disp -------------------------------
%         fprintf('Error in reading %s at Index: %d\n\n',fn_sac1,i)
%         fprintf('Following is the Report:\n')
        fprintf('\n%s\n',errmsg.getReport)
    end
end

%% Nested function

% wtSAC: write out one sac file
function wtSAC(sacst1,fn_sac1,str_endian)
    
% define empty sac head
h = zeros(302,1);
h(1:110) = -12345*ones(110,1);
h(106) = 1; % leven is set to true

% check sac head for completeness and consistency

msg_id = 'SACST_fwrite:wtSAC:HeaderChk';

% check the sacst1
if sacst1.leven ~= 1
    msg = 'sacst1.leven(equidistant sampling) is not set to 1, changed to 1 !';
    warning(msg_id,msg);
    sacst1.leven = 1;
end

if sacst1.delta == -12345
    msg = 'sacst1.delta is not set!';
    error(msg_id,msg);
end

if length(sacst1.data) ~= sacst1.npts
    msg = 'sacst1.npts is not correct, changed to the length of sac data!';
    warning(msg_id,msg);
    sacst1.npts = length(sacst1.data);
end

if sacst1.b == -12345
    msg = 'sacst1.b is not set, changed to 0 !';
    warning(msg_id,msg);
    sacst1.b = 0;
end

end_time = sacst1.b+(sacst1.npts-1)*sacst1.delta;
if abs(sacst1.e - end_time) > sacst1.delta/10
    msg = ['sacst1.e is changed from ',num2str(sacst1.e),' to ',num2str(end_time)];
    warning(msg_id,msg);
    sacst1.e = end_time;
end

if sacst1.iftype ~= 1 % time series file
    msg = 'sacst1.iftype is set to 1!';
    warning(msg_id,msg);
    sacst1.iftype = 1;
end

if sacst1.nvhdr ~= 6 % version number
    msg = 'sacst1.nvhdr is set to 6!';
    warning(msg_id,msg);
    sacst1.nvhdr = 6;
end

% if (sacst1.evla ~= -12345 && ...
%         sacst1.evlo ~= -12345 && ...
%         sacst1.stla ~= -12345 && ...
%         sacst1.stlo ~= -12345)
%     [sacst1.dist, sacst1.az, sacst1.baz, sacst1.gcarc] = ical(sacst1.stla,sacst1.stlo,sacst1.evla,sacst1.evlo);
% end

% read real header variables
h(1) = sacst1.delta;
h(2) = sacst1.depmin;
h(3) = sacst1.depmax;
h(4) = sacst1.scale;
h(5) = sacst1.odelta;
h(6) = sacst1.b;
h(7) = sacst1.e;
h(8) = sacst1.o;
h(9) = sacst1.a;
h(11) = sacst1.t0;
h(12) = sacst1.t1;
h(13) = sacst1.t2;
h(14) = sacst1.t3;
h(15) = sacst1.t4;
h(16) = sacst1.t5;
h(17) = sacst1.t6;
h(18) = sacst1.t7;
h(19) = sacst1.t8;
h(20) = sacst1.t9;
h(21) = sacst1.f;
h(22) = sacst1.resp0;
h(23) = sacst1.resp1;
h(24) = sacst1.resp2;
h(25) = sacst1.resp3;
h(26) = sacst1.resp4;
h(27) = sacst1.resp5;
h(28) = sacst1.resp6;
h(29) = sacst1.resp7;
h(30) = sacst1.resp8;
h(31) = sacst1.resp9;
h(32) = sacst1.stla;
h(33) = sacst1.stlo;
h(34) = sacst1.stel;
h(35) = sacst1.stdp;
h(36) = sacst1.evla;
h(37) = sacst1.evlo;
h(38) = sacst1.evel;
h(39) = sacst1.evdp;
h(40) = sacst1.mag;
h(41) = sacst1.user0;
h(42) = sacst1.user1;
h(43) = sacst1.user2;
h(44) = sacst1.user3;
h(45) = sacst1.user4;
h(46) = sacst1.user5;
h(47) = sacst1.user6;
h(48) = sacst1.user7;
h(49) = sacst1.user8;
h(50) = sacst1.user9;
h(51) = sacst1.dist;
h(52) = sacst1.az;
h(53) = sacst1.baz;
h(54) = sacst1.gcarc;
h(57) = sacst1.depmen;
h(58) = sacst1.cmpaz;
h(59) = sacst1.cmpinc;
h(60) = sacst1.xminimum;
h(61) = sacst1.xmaximum;
h(62) = sacst1.yminimum;
h(63) = sacst1.ymaximum;

% read integer header variables
h(71) = sacst1.nzyear;
h(72) = sacst1.nzjday;
h(73) = sacst1.nzhour;
h(74) = sacst1.nzmin;
h(75) = sacst1.nzsec;
h(76) = sacst1.nzmsec;
h(77) = sacst1.nvhdr;
h(78) = sacst1.norid;
h(79) = sacst1.nevid;
h(80) = sacst1.npts;
h(82) = sacst1.nwfid;
h(83) = sacst1.nxsize;
h(84) = sacst1.nysize;
h(86) = sacst1.iftype;
h(87) = sacst1.idep;
h(88) = sacst1.iztype;
h(90) = sacst1.iinst;
h(91) = sacst1.istreg;
h(92) = sacst1.ievreg;
h(93) = sacst1.ievtyp;
h(94) = sacst1.iqual;
h(95) = sacst1.isynth;
h(96) = sacst1.imagtyp;
h(97) = sacst1.imagsrc;

% read logical header variables
h(106) = sacst1.leven; 
h(107) = sacst1.lpspol;
h(108) = sacst1.lovrok;
h(109) = sacst1.lcalda;

% read character header variables
h(111:118) = istrchoppad(sacst1.kstnm,8);
h(119:134) = istrchoppad(sacst1.kevnm,16);
h(135:142) = istrchoppad(sacst1.khole,8);
h(143:150) = istrchoppad(sacst1.ko,8); 
h(151:158) = istrchoppad(sacst1.ka,8); 
h(159:166) = istrchoppad(sacst1.kt0,8);
h(167:174) = istrchoppad(sacst1.kt1,8);
h(175:182) = istrchoppad(sacst1.kt2,8);
h(183:190) = istrchoppad(sacst1.kt3,8);
h(191:198) = istrchoppad(sacst1.kt4,8);
h(199:206) = istrchoppad(sacst1.kt5,8);
h(207:214) = istrchoppad(sacst1.kt6,8);
h(215:222) = istrchoppad(sacst1.kt7,8);
h(223:230) = istrchoppad(sacst1.kt8,8);
h(231:238) = istrchoppad(sacst1.kt9,8);
h(239:246) = istrchoppad(sacst1.kf,8); 
h(247:254) = istrchoppad(sacst1.kuser0,8);
h(255:262) = istrchoppad(sacst1.kuser1,8);
h(263:270) = istrchoppad(sacst1.kuser2,8);
h(271:278) = istrchoppad(sacst1.kcmpnm,8);
h(279:286) = istrchoppad(sacst1.knetwk,8);
h(287:294) = istrchoppad(sacst1.kdatrd,8);
h(295:302) = istrchoppad(sacst1.kinst,8);

% write sac head and data
fid = fopen(fn_sac1,'w',str_endian);
% write single precision(4*bytes = 32*bits) real header variables:
fwrite(fid,h(1:70),'single');
% write single precision integer header variables:
fwrite(fid,h(71:105),'int32');
% write logical header variables
fwrite(fid,h(106:110),'int32');
% write character header variables
fwrite(fid,h(111:302),'char');
% write sac data
fwrite(fid,sacst1.data,'single');
%
fclose(fid);
end

% istrchoppad: chop or pad the input string to a given length
function [ strout ] = istrchoppad( strin, strlen )

    nstrin = length(strin);
    if nstrin < strlen
        strout = strin;    
        strout(nstrin+1:strlen) = 0;
    else
        strout = strin(1:strlen);
    end
end

%     function [dist, az, baz, gcarc] = ical(stla,stlo,evla,evlo)
%         R_earth = 6371.009; % mean earth's radius(km)
%         radperdeg = pi/180;
%         degperrad = 180/pi;
%         n_st = [cos(stlo*radperdeg), sin(stlo*radperdeg), sin(stla*radperdeg)];
%         n_ev = [cos(evlo*radperdeg), sin(evlo*radperdeg), sin(evla*radperdeg)];
%         n_north = [0 0 1];
%         
%         % calculate epidistance:
%         dist = acos(dot(n_st,n_ev))*R_earth;
%         % calculate great circle arc:
%         gcarc = acos(dot(n_st,n_ev))*degperrad;
%         % calculate azimuth:
%         evrotnorth = cross(n_ev,n_north);
%         evrotst = cross(n_ev,n_st);
%         az_pi = acos(dot(evrotnorth,evrotst));
%         if dot(cross(evrotnorth,n_ev),evrotst)>0
%             az = az_pi*degperrad;
%         else
%             az = (2*pi-az_pi)*degperrad;
%         end
%         % calculate back-azimuth:
%         strotnorth = cross(n_st,n_north);
%         strotev = cross(n_st,n_ev);
%         baz_pi = acos(dot(strotnorth,strotev));
%         if dot(cross(strotnorth,n_st),strotev)>0
%             baz = baz_pi*degperrad;
%         else
%             baz = (2*pi-baz_pi)*degperrad;
%         end
%     end

end
