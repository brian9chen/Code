function [ sac_st ] = SAC_fread( fn_sac )
% SAC_read reads a sac file and outputs a structure containing the sac header and the data.
%--------------------------------------------------------------------------
% Usage: [ sac_st ] = SAC_read( fn_sac )
%--------------------------------------------------------------------------
% Input:
%   fn_sac: input sac file name
%--------------------------------------------------------------------------
% Output
%   sac_st: a structure containing sac header and data
%
% sac header contains the following elements
%--------------------------------------------------------------------------
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
%response is a 10-element array, and trcLen is a scalar. 
%--------------------------------------------------------------------------
% Notes: 
%   2011-12-16: modified
%--------------------------------------------------------------------------

%% check byte-order
%    Default byte-order
%    endian  = 'big'  big-endian byte order (e.g., UNIX)
%            = 'lil'  little-endian byte order (e.g., LINUX)

fid_lil = fopen(fn_sac,'r','ieee-le'); 
fid_big = fopen(fn_sac,'r','ieee-be');

% check header version == 6 and the byte order
%--------------------------------------------------------------------------
% If the header version is not NVHDR == 6 then the sacfile is likely of the
% opposite byte order.  This will give h(77) some ridiculously large
% number.  NVHDR can also be 4 or 5.  In this case it is an old SAC file
% and rdsac cannot read this file in.  To correct, read the SAC file into
% the newest verson of SAC and w over.
if fseek(fid_lil,304,'bof')==0 && fseek(fid_big,304,'bof')==0
    nvhdr_lil = fread(fid_lil,1,'int32');
    nvhdr_big = fread(fid_big,1,'int32');
else
    message = 'Failed to read sac file!';
    error(message)
end
    
if nvhdr_lil == 6
    fid = fid_lil;
%     disp('little-endian byte order!')
    fseek(fid,0,'bof');
    fclose(fid_big);
elseif nvhdr_big == 6
    fid = fid_big;
%     disp('big-endian byte order!')
    fseek(fid,0,'bof');
    fclose(fid_lil);
else
    message = ['Not sac format! nvhdr ~= 6: nvhdr_lil = ',num2str(nvhdr_lil),', nvhdr_big = ',num2str(nvhdr_big)];
    error(message)
end

%% read in sac header
h = zeros(1,302);

% read in 70*(single precision real) header variables:
h(1:70) = fread(fid,70,'single');

% read in 35*(single precision interger) header variables:
h(71:105) = fread(fid,35,'int32');

% read in 4*logical(single precision interger) header variables
h(106:110) = fread(fid,5,'int32');

% read in 192*char header variables
h(111:302) = fread(fid,192,'char');

% add header signature for testing files for SAC format
%---------------------------------------------------------------------------
% h(303) = 84;
% h(304) = 65;
% h(305) = 79;

%% write sac header into sac_st

% read real header variables
%---------------------------------------------------------------------------
sac_st.delta = h(1);
sac_st.depmin = h(2);
sac_st.depmax = h(3);
sac_st.scale = h(4);
sac_st.odelta = h(5);
sac_st.b = h(6);
sac_st.e = h(7);
sac_st.o = h(8);
sac_st.a = h(9);
sac_st.t0 = h(11);
sac_st.t1 = h(12);
sac_st.t2 = h(13);
sac_st.t3 = h(14);
sac_st.t4 = h(15);
sac_st.t5 = h(16);
sac_st.t6 = h(17);
sac_st.t7 = h(18);
sac_st.t8 = h(19);
sac_st.t9 = h(20);
sac_st.f = h(21);
sac_st.resp0 = h(22);
sac_st.resp1 = h(23);
sac_st.resp2 = h(24);
sac_st.resp3 = h(25);
sac_st.resp4 = h(26);
sac_st.resp5 = h(27);
sac_st.resp6 = h(28);
sac_st.resp7 = h(29);
sac_st.resp8 = h(30);
sac_st.resp9 = h(31);
sac_st.stla = h(32);
sac_st.stlo = h(33);
sac_st.stel = h(34);
sac_st.stdp = h(35);
sac_st.evla = h(36);
sac_st.evlo = h(37);
sac_st.evel = h(38);
sac_st.evdp = h(39);
sac_st.mag = h(40);
sac_st.user0 = h(41);
sac_st.user1 = h(42);
sac_st.user2 = h(43);
sac_st.user3 = h(44);
sac_st.user4 = h(45);
sac_st.user5 = h(46);
sac_st.user6 = h(47);
sac_st.user7 = h(48);
sac_st.user8 = h(49);
sac_st.user9 = h(50);
sac_st.dist = h(51);
sac_st.az = h(52);
sac_st.baz = h(53);
sac_st.gcarc = h(54);
sac_st.depmen = h(57);
sac_st.cmpaz = h(58);
sac_st.cmpinc = h(59);
sac_st.xminimum = h(60);
sac_st.xmaximum = h(61);
sac_st.yminimum = h(62);
sac_st.ymaximum = h(63);

% read integer header variables
%---------------------------------------------------------------------------
sac_st.nzyear = round(h(71));
sac_st.nzjday = round(h(72));
sac_st.nzhour = round(h(73));
sac_st.nzmin = round(h(74));
sac_st.nzsec = round(h(75));
sac_st.nzmsec = round(h(76));
sac_st.nvhdr = round(h(77));
sac_st.norid = round(h(78));
sac_st.nevid = round(h(79));
sac_st.npts = round(h(80));
sac_st.nwfid = round(h(82));
sac_st.nxsize = round(h(83));
sac_st.nysize = round(h(84));
sac_st.iftype = round(h(86));
sac_st.idep = round(h(87));
sac_st.iztype = round(h(88));
sac_st.iinst = round(h(90));
sac_st.istreg = round(h(91));
sac_st.ievreg = round(h(92));
sac_st.ievtyp = round(h(93));
sac_st.iqual = round(h(94));
sac_st.isynth = round(h(95));
sac_st.imagtyp = round(h(96));
sac_st.imagsrc = round(h(97));

%read logical header variables
%---------------------------------------------------------------------------
sac_st.leven = round(h(106));
sac_st.lpspol = round(h(107));
sac_st.lovrok = round(h(108));
sac_st.lcalda = round(h(109));

%read character header variables
%---------------------------------------------------------------------------
sac_st.kstnm = char(h(111:118));
sac_st.kevnm = char(h(119:134));
sac_st.khole = char(h(135:142));
sac_st.ko = char(h(143:150));
sac_st.ka = char(h(151:158));
sac_st.kt0 = char(h(159:166));
sac_st.kt1 = char(h(167:174));
sac_st.kt2 = char(h(175:182));
sac_st.kt3 = char(h(183:190));
sac_st.kt4 = char(h(191:198));
sac_st.kt5 = char(h(199:206));
sac_st.kt6 = char(h(207:214));
sac_st.kt7 = char(h(215:222));
sac_st.kt8 = char(h(223:230));
sac_st.kt9 = char(h(231:238));
sac_st.kf = char(h(239:246));
sac_st.kuser0 = char(h(247:254));
sac_st.kuser1 = char(h(255:262));
sac_st.kuser2 = char(h(263:270));
sac_st.kcmpnm = char(h(271:278));
sac_st.knetwk = char(h(279:286));
sac_st.kdatrd = char(h(287:294));
sac_st.kinst = char(h(295:302));

%% write sac data

sac_st.data = fread(fid,sac_st.npts,'single');

fclose(fid);
end