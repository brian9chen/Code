function [ sachd, sacdata ] = irdsac( sacfile )
% irdsac generates a structure 'sachd' and a vector 'sacdata' from an 
% exist sac file.
%
% 'sachd' contains the following elements
% -------------------------------------------------------------------------
%delta	stla	evla	data(10) iftype   dist     xminimum             trcLen	
%b      stlo	evlo	label(3) idep     az       xmaximum             scale
%e      stel	evel             iztype   baz      yminimum
%o      stdp	evdp             iinst    gcarc    ymaximum
%a      cmpaz	nzyear           istreg	  norid
%t0     cmpinc	nzjday           ievreg	  nevid
%t1     kstnm	nzhour           ievtyp	  nwfid
%t2     kcmpnm	nzmin            iqual	  nxsize
%t3     knetwk	nzsec            isynth	  nysize
%t4		nzmsec
%t5		kevnm
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

%response is a 10-element array, and trcLen is a scalar. 
%
% author: taokai@pku.edu.cn (any suggestion is appreciated)

%% 
%    Default byte-order
%    endian  = 'big'  big-endian byte order (e.g., UNIX)
%            = 'lil'  little-endian byte order (e.g., LINUX)

endian = 'big';

if strcmp(endian,'big')
  fid = fopen(sacfile,'r','ieee-be'); 
elseif strcmp(endian,'lil')
  fid = fopen(sacfile,'r','ieee-le'); 
end

%% read in sac header
h = zeros(302,1);

% read in single precision real header variables:
%---------------------------------------------------------------------------
for i=1:70
  h(i) = fread(fid,1,'single');
end

% read in single precision integer header variables:
%---------------------------------------------------------------------------
for i=71:105
  h(i) = fread(fid,1,'int32');
end


% Check header version = 6 and issue warning
%---------------------------------------------------------------------------
% If the header version is not NVHDR == 6 then the sacfile is likely of the
% opposite byte order.  This will give h(77) some ridiculously large
% number.  NVHDR can also be 4 or 5.  In this case it is an old SAC file
% and rsac cannot read this file in.  To correct, read the SAC file into
% the newest verson of SAC and w over.
% 
if (h(77) == 4 || h(77) == 5)
    message = strcat('NVHDR = 4 or 5. File: "',sacfile,'" may be from an old version of SAC.'); 
    error(message)
elseif h(77) ~= 6
    message = strcat('Current rsac byte order: "',endian,'". File: "',sacfile,'" may be of opposite byte-order.');
    error(message)
end

% read in logical header variables
%---------------------------------------------------------------------------
for i=106:110
  h(i) = fread(fid,1,'int32');
end

% read in character header variables
%---------------------------------------------------------------------------
for i=111:302
  h(i) = (fread(fid,1,'char'))';
end

% add header signature for testing files for SAC format
%---------------------------------------------------------------------------
% h(303) = 84;
% h(304) = 65;
% h(305) = 79;

%% write the structured sachd

% read real header variables
%---------------------------------------------------------------------------
sachd.delta = h(1);
sachd.depmin = h(2);
sachd.depmax = h(3);
sachd.scale = h(4);
sachd.odelta = h(5);
sachd.b = h(6);
sachd.e = h(7);
sachd.o = h(8);
sachd.a = h(9);
sachd.t0 = h(11);
sachd.t1 = h(12);
sachd.t2 = h(13);
sachd.t3 = h(14);
sachd.t4 = h(15);
sachd.t5 = h(16);
sachd.t6 = h(17);
sachd.t7 = h(18);
sachd.t8 = h(19);
sachd.t9 = h(20);
sachd.f = h(21);
sachd.resp0 = h(22);
sachd.resp1 = h(23);
sachd.resp2 = h(24);
sachd.resp3 = h(25);
sachd.resp4 = h(26);
sachd.resp5 = h(27);
sachd.resp6 = h(28);
sachd.resp7 = h(29);
sachd.resp8 = h(30);
sachd.resp9 = h(31);
sachd.stla = h(32);
sachd.stlo = h(33);
sachd.stel = h(34);
sachd.stdp = h(35);
sachd.evla = h(36);
sachd.evlo = h(37);
sachd.evel = h(38);
sachd.evdp = h(39);
sachd.mag = h(40);
sachd.user0 = h(41);
sachd.user1 = h(42);
sachd.user2 = h(43);
sachd.user3 = h(44);
sachd.user4 = h(45);
sachd.user5 = h(46);
sachd.user6 = h(47);
sachd.user7 = h(48);
sachd.user8 = h(49);
sachd.user9 = h(50);
sachd.dist = h(51);
sachd.az = h(52);
sachd.baz = h(53);
sachd.gcarc = h(54);
sachd.depmen = h(57);
sachd.cmpaz = h(58);
sachd.cmpinc = h(59);
sachd.xminimum = h(60);
sachd.xmaximum = h(61);
sachd.yminimum = h(62);
sachd.ymaximum = h(63);

% read integer header variables
%---------------------------------------------------------------------------
sachd.nzyear = round(h(71));
sachd.nzjday = round(h(72));
sachd.nzhour = round(h(73));
sachd.nzmin = round(h(74));
sachd.nzsec = round(h(75));
sachd.nzmsec = round(h(76));
sachd.nvhdr = round(h(77));
sachd.norid = round(h(78));
sachd.nevid = round(h(79));
sachd.npts = round(h(80));
sachd.nwfid = round(h(82));
sachd.nxsize = round(h(83));
sachd.nysize = round(h(84));
sachd.iftype = round(h(86));
sachd.idep = round(h(87));
sachd.iztype = round(h(88));
sachd.iinst = round(h(90));
sachd.istreg = round(h(91));
sachd.ievreg = round(h(92));
sachd.ievtyp = round(h(93));
sachd.iqual = round(h(94));
sachd.isynth = round(h(95));
sachd.imagtyp = round(h(96));
sachd.imagsrc = round(h(97));

%read logical header variables
%---------------------------------------------------------------------------
sachd.leven = round(h(106));
sachd.lpspol = round(h(107));
sachd.lovrok = round(h(108));
sachd.lcalda = round(h(109));

%read character header variables
%---------------------------------------------------------------------------
sachd.kstnm = char(h(111:118));
sachd.kevnm = char(h(119:134));
sachd.khole = char(h(135:142));
sachd.ko = char(h(143:150));
sachd.ka = char(h(151:158));
sachd.kt0 = char(h(159:166));
sachd.kt1 = char(h(167:174));
sachd.kt2 = char(h(175:182));
sachd.kt3 = char(h(183:190));
sachd.kt4 = char(h(191:198));
sachd.kt5 = char(h(199:206));
sachd.kt6 = char(h(207:214));
sachd.kt7 = char(h(215:222));
sachd.kt8 = char(h(223:230));
sachd.kt9 = char(h(231:238));
sachd.kf = char(h(239:246));
sachd.kuser0 = char(h(247:254));
sachd.kuser1 = char(h(255:262));
sachd.kuser2 = char(h(263:270));
sachd.kcmpnm = char(h(271:278));
sachd.knetwk = char(h(279:286));
sachd.kdatrd = char(h(287:294));
sachd.kinst = char(h(295:302));

%% read in amplitudes
if nargout == 2
    sacdata     = fread(fid,sachd.npts,'single');
end

fclose(fid);
end