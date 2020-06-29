function [ sacst ] = SACST_fread( varargin )
%reads a sac file or an input list of sac files and generates the SAC
%struct array.
%--------------------------------------------------------------------------
%Syntax:
%
%   [ sac_st ] = SACST_fread( fn_sac )
%   [ sac_st ] = SACST_fread( ..., 'list',fn_saclist )
%   [ sac_st ] = SACST_fread( ..., 'list',fn_saclist, 'PropertyName', PropertyValue )
%--------------------------------------------------------------------------
%Description:
%
%   [ sac_st ] = SACST_fread(fn_sac) outputs the SAC struct SACST from the
%   SAC file names in the cell string: fn_sac;
%
%   [ sac_st ] = SACST_fread(fn_sac,'list',fn_saclist) outputs the SAC struct array
%   from SAC files in fn_sac and also SAC files listed in fn_saclist; 
% 
%   [ sac_st ] = SACST_fread(fn_sac,'list',fn_saclist,'PropertyName',
%   PropertyValue)
%--------------------------------------------------------------------------
%PropertyName   | PropertyValue     | Description
%   
%   'list'      |   string          | sac file list
%   'prefix'    |   string          | add before fn_sac or sac names in 'list'
%   'suffix'    |   cellstr or str  | add after fn_sac or sac names in 'list'
%       
% e.g. fn_sac = [prefix, sacnm, suffix] will be used to access the SAC
% file.
% 
%--------------------------------------------------------------------------
%The SACST fields are listed below:
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
%   sacst = SACST_fread({'sacnm1','sacnm2',...},'list','SAC_list','prefix','somedir/','suffix','.BHZ' )
%--------------------------------------------------------------------------
%History: 
%
%   [2011-12-16] modified
%--------------------------------------------------------------------------

%% Parse the input argument

% define the object: inputParser
p = inputParser;
% get parameters
p.addOptional('sacnm',{},@iscellstr)
% p.addOptional('sacnm',{},@ischar)
p.addParamValue('list',[],@(name) exist(name,'file'));
p.addParamValue('prefix',[],@ischar);
p.addParamValue('suffix',[],@(suffix) ischar(suffix)||iscellstr(suffix));
% p.KeepUnmatched = true;
% parsing arguments
p.parse(varargin{:});

%% Get all SAC file names

if ~isempty(p.Results.list)
    fid = fopen(p.Results.list,'r');
    saclist = textscan(fid,'%s');
    fclose(fid);
    sacnm = [reshape(p.Results.sacnm,[],1); saclist{1}];
else
    sacnm = reshape(p.Results.sacnm,[],1);
end

suffix = p.Results.suffix;

%% Generate SACST
% number of SAC files
Nsac = length(sacnm);
Nsuffix = 1;
if iscellstr(suffix)
    Nsuffix = length(suffix);
else
    suffix = {suffix};
end
%
sacst = SACST_new(Nsac,Nsuffix);
for idx_sac=1:Nsac
    for idx_suffix = 1:Nsuffix
        fn_sac1 = [p.Results.prefix,sacnm{idx_sac},suffix{idx_suffix}];
        try 
            sacst(idx_sac,idx_suffix) = rdSAC(fn_sac1);
        catch errmsg
    %         disp(errmsg.MException)
            disp -------------------------------
            fprintf('Error in reading SAC file #%d: %s\n',idx_sac,fn_sac1)
            disp -------------------------------
    %         fprintf('Error in reading %s at Index: %d\n\n',fn_sac1,i)
    %         fprintf('Following is the Report:\n')
            fprintf('\n%s\n',errmsg.getReport)
            %
    %         sacst(i) = SACST_new;
        end
    end
end

%% Nested function: 

% rdSAC: read one sac file and output the single SAC struct
    function sacst1 = rdSAC(fn_sac1)
        %-------------------------------------------------
        % Check for byte-order
        %    Default byte-order
        %    endian  = 'big'  big-endian byte order (e.g., UNIX)
        %            = 'lil'  little-endian byte order (e.g., LINUX)

        fid_lil = fopen(fn_sac1,'r','ieee-le'); 
        fid_big = fopen(fn_sac1,'r','ieee-be');

        % check header version == 6 and the byte order
        % If the header version is not NVHDR == 6 then the sacfile is likely of the
        % opposite byte order.  This will give h(77) some ridiculously large
        % number.  NVHDR can also be 4 or 5.  In this case it is an old SAC file
        % and rdsac cannot read this file in.  To correct, read the SAC file into
        % the newest verson of SAC and w over.
        if fseek(fid_lil,304,'bof')==0 && fseek(fid_big,304,'bof')==0
            nvhdr_lil = fread(fid_lil,1,'int32');
            nvhdr_big = fread(fid_big,1,'int32');
        else
            msgID = 'SACST_fread:rdSAC:fileChk';
            errmsg = 'Failed to read %s\n';
            error(msgID,errmsg,fn_sac1)
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
            msgID = 'SACST_fread:rdSAC:fileChk';
            errmsg = '%s is Not SAC format because nvhdr ~= 6 (nvhdr_lil = %d, nvhdr_big = %d)\n';
            error(msgID,errmsg,fn_sac1,nvhdr_lil,nvhdr_big)
        end

        %-------------------------------------------------
        % Read SAC header field
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
        % h(303) = 84;
        % h(304) = 65;
        % h(305) = 79;

        %-------------------------------------------------
        % set SACST
        
        % set real header variables
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

        % read integer header variables
        sacst1.nzyear = round(h(71));
        sacst1.nzjday = round(h(72));
        sacst1.nzhour = round(h(73));
        sacst1.nzmin = round(h(74));
        sacst1.nzsec = round(h(75));
        sacst1.nzmsec = round(h(76));
        sacst1.nvhdr = round(h(77));
        sacst1.norid = round(h(78));
        sacst1.nevid = round(h(79));
        sacst1.npts = round(h(80));
        sacst1.nwfid = round(h(82));
        sacst1.nxsize = round(h(83));
        sacst1.nysize = round(h(84));
        sacst1.iftype = round(h(86));
        sacst1.idep = round(h(87));
        sacst1.iztype = round(h(88));
        sacst1.iinst = round(h(90));
        sacst1.istreg = round(h(91));
        sacst1.ievreg = round(h(92));
        sacst1.ievtyp = round(h(93));
        sacst1.iqual = round(h(94));
        sacst1.isynth = round(h(95));
        sacst1.imagtyp = round(h(96));
        sacst1.imagsrc = round(h(97));

        %set logical header variables
        sacst1.leven = round(h(106));
        sacst1.lpspol = round(h(107));
        sacst1.lovrok = round(h(108));
        sacst1.lcalda = round(h(109));

        %set character header variables
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

        % set data field
        sacst1.data = fread(fid,sacst1.npts,'single');
         
        % set sac file name (only used for checking)
%         sacst1.file = fn_sac1;
        
        fclose(fid);
    end

end