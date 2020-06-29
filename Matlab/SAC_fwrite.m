function SAC_fwrite( sac_st, fn_sac )
% SAC_write writes an ASCII sac file from the input sac structure
%--------------------------------------------------------------------------
% Usage: SAC_write( sac_st, fn_sac )
%--------------------------------------------------------------------------
% Input:
%   sac_st: sac structure;
%   fn_sac: output sac file name;
%--------------------------------------------------------------------------
% Note:
%   2011-12-16: modified;
%       az, baz, gcarc, dist are NOT calculated based on
%       evla,evlo,stla,stlo
%--------------------------------------------------------------------------

%% Check endianess of the computer

%    endian  = 'big'  big-endian byte order (e.g., UNIX)
%            = 'lil'  little-endian byte order (e.g., LINUX)

[computerType, maxSize, endian] = computer;

if strcmp(endian,'B')
    fid = fopen(fn_sac,'w','ieee-be'); 
elseif strcmp(endian,'L')
    fid = fopen(fn_sac,'w','ieee-le'); 
end

%% define empty sac head
h = zeros(302,1);
h(1:110) = -12345*ones(110,1);
h(106) = 1; % leven is set to true

%% check sac head for completeness and consistency

msg_id = 'wtSAC:paraIncomplete';

% check the sac_st
if sac_st.leven ~= 1
    msg = 'sac_st.leven(equidistant sampling) is not set to 1, changed to 1 !';
    warning(msg_id,msg);
    sac_st.leven = 1;
end

if sac_st.delta == -12345
    msg = 'sac_st.delta is not set!';
    error(msg_id,msg);
end

if length(sac_st.data) ~= sac_st.npts
    msg = 'sac_st.npts is not correct, changed to the length of sac data!';
    warning(msg_id,msg);
    sac_st.npts = length(sac_st.data);
end

if sac_st.b == -12345
    msg = 'sac_st.b is not set, changed to 0 !';
    warning(msg_id,msg);
    sac_st.b = 0;
end

end_time = sac_st.b+(sac_st.npts-1)*sac_st.delta;
if abs(sac_st.e - end_time) > sac_st.delta/10
    msg = ['sac_st.e is changed from ',num2str(sac_st.e),' to ',num2str(end_time)];
    warning(msg_id,msg);
    sac_st.e = end_time;
end

if sac_st.iftype ~= 1 % time series file
    msg = 'sac_st.iftype is set to 1!';
    warning(msg_id,msg);
    sac_st.iftype = 1;
end

if sac_st.nvhdr ~= 6 % version number
    msg = 'sac_st.nvhdr is set to 6!';
    warning(msg_id,msg);
    sac_st.nvhdr = 6;
end

% if (sac_st.evla ~= -12345 && ...
%         sac_st.evlo ~= -12345 && ...
%         sac_st.stla ~= -12345 && ...
%         sac_st.stlo ~= -12345)
%     [sac_st.dist, sac_st.az, sac_st.baz, sac_st.gcarc] = ical(sac_st.stla,sac_st.stlo,sac_st.evla,sac_st.evlo);
% end

%% read real header variables

h(1)     =    sac_st.delta    ;
h(2)               =    sac_st.depmin   ;
h(3)               =    sac_st.depmax   ;
h(4)                =    sac_st.scale    ;
h(5)               =    sac_st.odelta   ;
h(6)                    =    sac_st.b        ;
h(7)                    =    sac_st.e        ;
h(8)                    =    sac_st.o        ;
h(9)                    =    sac_st.a        ;
h(11)                  =    sac_st.t0       ;
h(12)                  =    sac_st.t1       ;
h(13)                  =    sac_st.t2       ;
h(14)                  =    sac_st.t3       ;
h(15)                  =    sac_st.t4       ;
h(16)                  =    sac_st.t5       ;
h(17)                  =    sac_st.t6       ;
h(18)                  =    sac_st.t7       ;
h(19)                  =    sac_st.t8       ;
h(20)                  =    sac_st.t9       ;
h(21)                   =    sac_st.f        ;
h(22)               =    sac_st.resp0    ;
h(23)               =    sac_st.resp1    ;
h(24)               =    sac_st.resp2    ;
h(25)               =    sac_st.resp3    ;
h(26)               =    sac_st.resp4    ;
h(27)               =    sac_st.resp5    ;
h(28)               =    sac_st.resp6    ;
h(29)               =    sac_st.resp7    ;
h(30)               =    sac_st.resp8    ;
h(31)               =    sac_st.resp9    ;
h(32)                =    sac_st.stla     ;
h(33)                =    sac_st.stlo     ;
h(34)                =    sac_st.stel     ;
h(35)                =    sac_st.stdp     ;
h(36)                =    sac_st.evla     ;
h(37)                =    sac_st.evlo     ;
h(38)                =    sac_st.evel     ;
h(39)                =    sac_st.evdp     ;
h(40)                 =    sac_st.mag      ;
h(41)               =    sac_st.user0    ;
h(42)               =    sac_st.user1    ;
h(43)               =    sac_st.user2    ;
h(44)               =    sac_st.user3    ;
h(45)               =    sac_st.user4    ;
h(46)               =    sac_st.user5    ;
h(47)               =    sac_st.user6    ;
h(48)               =    sac_st.user7    ;
h(49)               =    sac_st.user8    ;
h(50)               =    sac_st.user9    ;
h(51)                =    sac_st.dist     ;
h(52)                  =    sac_st.az       ;
h(53)                 =    sac_st.baz      ;
h(54)               =    sac_st.gcarc    ;
h(57)              =    sac_st.depmen   ;
h(58)               =    sac_st.cmpaz    ;
h(59)              =    sac_st.cmpinc   ;
h(60)            =    sac_st.xminimum ;
h(61)            =    sac_st.xmaximum ;
h(62)            =    sac_st.yminimum ;
h(63)            =    sac_st.ymaximum ;

%% read integer header variables

h(71)         = sac_st.nzyear  ;
h(72)         = sac_st.nzjday  ;
h(73)         = sac_st.nzhour  ;
h(74)          = sac_st.nzmin   ;
h(75)          = sac_st.nzsec   ;
h(76)         = sac_st.nzmsec  ;
h(77)          = sac_st.nvhdr   ;
h(78)          = sac_st.norid   ;
h(79)          = sac_st.nevid   ;
h(80)           = sac_st.npts    ;
h(82)          = sac_st.nwfid   ;
h(83)         = sac_st.nxsize  ;
h(84)         = sac_st.nysize  ;
h(86)         = sac_st.iftype  ;
h(87)           = sac_st.idep    ;
h(88)         = sac_st.iztype  ;
h(90)          = sac_st.iinst   ;
h(91)         = sac_st.istreg  ;
h(92)         = sac_st.ievreg  ;
h(93)         = sac_st.ievtyp  ;
h(94)          = sac_st.iqual   ;
h(95)         = sac_st.isynth  ;
h(96)        = sac_st.imagtyp ;
h(97)        = sac_st.imagsrc ;

%% read logical header variables

h(106)           =   sac_st.leven ; 
h(107)           =  sac_st.lpspol ;
h(108)           =  sac_st.lovrok ;
h(109)           =  sac_st.lcalda ;

%% read character header variables

h(111:118)           =   istrchoppad(sac_st.kstnm  ,8);
h(119:134)           =   istrchoppad(sac_st.kevnm  ,16);
h(135:142)           =   istrchoppad(sac_st.khole  ,8);
h(143:150)           =   istrchoppad(sac_st.ko  	,8); 
h(151:158)           =   istrchoppad(sac_st.ka  	,8); 
h(159:166)           =   istrchoppad(sac_st.kt0  	,8);
h(167:174)         =     istrchoppad(sac_st.kt1    ,8);
h(175:182)         =     istrchoppad(sac_st.kt2    ,8);
h(183:190)         =     istrchoppad(sac_st.kt3    ,8);
h(191:198)         =     istrchoppad(sac_st.kt4    ,8);
h(199:206)         =     istrchoppad(sac_st.kt5    ,8);
h(207:214)         =     istrchoppad(sac_st.kt6    ,8);
h(215:222)         =     istrchoppad(sac_st.kt7    ,8);
h(223:230)         =     istrchoppad(sac_st.kt8    ,8);
h(231:238)         =     istrchoppad(sac_st.kt9    ,8);
h(239:246)           =   istrchoppad(sac_st.kf  	 ,8); 
h(247:254)            =  istrchoppad(sac_st.kuser0 ,8);
h(255:262)            =  istrchoppad(sac_st.kuser1 ,8);
h(263:270)            =  istrchoppad(sac_st.kuser2 ,8);
h(271:278)            =  istrchoppad(sac_st.kcmpnm ,8);
h(279:286)            =  istrchoppad(sac_st.knetwk ,8);
h(287:294)            =  istrchoppad(sac_st.kdatrd ,8);
h(295:302)           =   istrchoppad(sac_st.kinst  ,8);

%% write sac head and data

% write single precision real header variables:
for i=1:70
  fwrite(fid,h(i),'single');
end

% write single precision integer header variables:
for i=71:105
  fwrite(fid,h(i),'int32');
end

% write logical header variables
for i=106:110
  fwrite(fid,h(i),'int32');
end

% write character header variables
for i=111:302
  fwrite(fid,h(i),'char');
end

% write sac data
fwrite(fid,sac_st.data,'single');

fclose(fid);

%% nested funcitons
function [ strout ] = istrchoppad( strin, strlen )
% istrchoppad: chop or pad the input string to a given length
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
