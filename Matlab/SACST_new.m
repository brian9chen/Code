function [ sacst ] = SACST_new(varargin)
%creates an empty SAC struct array
%--------------------------------------------------------------------------
%Syntax:
% 
%   [ sacst ] = SAC_create(N)
%--------------------------------------------------------------------------
%Description:
%   [ sacst ] = SAC_create creates an empty SAC struct array of size one;
%   [ sacst ] = SAC_create(N) creates an empty SAC struct array of size N;
% 
%-------------------------------------------------------------------------- 
%The fields in SACST is listed below:
%
%delta	stla	evla	data(10) iftype   dist     xminimum      trcLen	
%b      stlo	evlo	label(3) idep     az       xmaximum      scale
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
%(response is a 10-element array, and trcLen is a scalar. )
%--------------------------------------------------------------------------
%History:
%
%   [2011-12-23]: modified
%       - default gmt time is set to (nzyear=2000,nzjday=1,nzhour=0,nzsec=0,nzmsec=0). This is the reference zero time used in SAC_gmt2sec;
%   [2012-02-12]: modified
%       - default gmt time is reset to -12345 (undef)
%   [2012-02-22]: now can ouput multi-dimensional struct 
%--------------------------------------------------------------------------

%% Parse the input argument
% p = inputParser;
% p.addOptional('num',1,@isvector)
% p.parse(varargin{:});
% % if nargin == 0
% %     N = 1;
% % end
% N = p.Results.num;
%% define empty SAC head fields
h = zeros(1,302);
h(1:97) = -12345*ones(1,97);
h(106) = 1; % leven is set to true(equidistant sampling)
h(108) = 1; % lovrok is set to true(overwirte is permitted, added on 3/6/2010)
h(109) = 1; % lcalda is set to true(calculate az,backaz,dist from evla/lo and stla/lo, added on 3/6/2010)

%% Generate SAC struct of size one

% real header variables
sacst1.delta = h(1);
sacst1.depmin = h(2);
sacst1.depmax = h(3);
sacst1.scale = h(4);
sacst1.odelta = h(5);
sacst1.b = h(6);
sacst1.e = h(7);
sacst1.o = h(8);
sacst1.a = h(9);
sacst1.t0 = h(11);
sacst1.t1 = h(12);
sacst1.t2 = h(13);
sacst1.t3 = h(14);
sacst1.t4 = h(15);
sacst1.t5 = h(16);
sacst1.t6 = h(17);
sacst1.t7 = h(18);
sacst1.t8 = h(19);
sacst1.t9 = h(20);
sacst1.f = h(21);
sacst1.resp0 = h(22);
sacst1.resp1 = h(23);
sacst1.resp2 = h(24);
sacst1.resp3 = h(25);
sacst1.resp4 = h(26);
sacst1.resp5 = h(27);
sacst1.resp6 = h(28);
sacst1.resp7 = h(29);
sacst1.resp8 = h(30);
sacst1.resp9 = h(31);
sacst1.stla = h(32);
sacst1.stlo = h(33);
sacst1.stel = h(34);
sacst1.stdp = h(35);
sacst1.evla = h(36);
sacst1.evlo = h(37);
sacst1.evel = h(38);
sacst1.evdp = h(39);
sacst1.mag = h(40);
sacst1.user0 = h(41);
sacst1.user1 = h(42);
sacst1.user2 = h(43);
sacst1.user3 = h(44);
sacst1.user4 = h(45);
sacst1.user5 = h(46);
sacst1.user6 = h(47);
sacst1.user7 = h(48);
sacst1.user8 = h(49);
sacst1.user9 = h(50);
sacst1.dist = h(51);
sacst1.az = h(52);
sacst1.baz = h(53);
sacst1.gcarc = h(54);
sacst1.depmen = h(57);
sacst1.cmpaz = h(58);
sacst1.cmpinc = h(59);
sacst1.xminimum = h(60);
sacst1.xmaximum = h(61);
sacst1.yminimum = h(62);
sacst1.ymaximum = h(63);

% integer header variables
sacst1.nzyear = h(71);
% sacst1.nzyear = 2000;
sacst1.nzjday = h(72);
% sacst1.nzjday = 1;
sacst1.nzhour = h(73);
% sacst1.nzhour = 0;
sacst1.nzmin = h(74);
% sacst1.nzmin = 0;
sacst1.nzsec = h(75);
% sacst1.nzsec = 0;
sacst1.nzmsec = h(76);
% sacst1.nzmsec = 0;
sacst1.nvhdr = h(77);
sacst1.norid = h(78);
sacst1.nevid = h(79);
sacst1.npts = h(80);
sacst1.nwfid = h(82);
sacst1.nxsize = h(83);
sacst1.nysize = h(84);
sacst1.iftype = h(86);
sacst1.idep = h(87);
sacst1.iztype = h(88);
sacst1.iinst = h(90);
sacst1.istreg = h(91);
sacst1.ievreg = h(92);
sacst1.ievtyp = h(93);
sacst1.iqual = h(94);
sacst1.isynth = h(95);
sacst1.imagtyp = h(96);
sacst1.imagsrc = h(97);

% logical header variables
sacst1.leven = h(106);
sacst1.lpspol = h(107);
sacst1.lovrok = h(108);
sacst1.lcalda = h(109);

% character header variables
sacst1.kstnm = char(h(111:118));
sacst1.kevnm = char(h(119:134));
sacst1.khole = char(h(135:142));
sacst1.ko = char(h(143:150));
sacst1.ka = char(h(151:158));
sacst1.kt0 = char(h(159:166));
sacst1.kt1 = char(h(167:174));
sacst1.kt2 = char(h(175:182));
sacst1.kt3 = char(h(183:190));
sacst1.kt4 = char(h(191:198));
sacst1.kt5 = char(h(199:206));
sacst1.kt6 = char(h(207:214));
sacst1.kt7 = char(h(215:222));
sacst1.kt8 = char(h(223:230));
sacst1.kt9 = char(h(231:238));
sacst1.kf = char(h(239:246));
sacst1.kuser0 = char(h(247:254));
sacst1.kuser1 = char(h(255:262));
sacst1.kuser2 = char(h(263:270));
sacst1.kcmpnm = char(h(271:278));
sacst1.knetwk = char(h(279:286));
sacst1.kdatrd = char(h(287:294));
sacst1.kinst = char(h(295:302));

% sac data
sacst1.data = ones(0,1);

%% Generate SAC struct array

if nargin == 0
    sacst = sacst1;
else
    sacst(varargin{:}) = sacst1;
    sacst(:) = sacst1;
end
% for i=1:N-1
%     sacst(i) = sacst1;
% end

end