function [ abstime ] = gmt2sec_SHD( sachd, tmarker )
%--------------------------------------------------------------------------
% GMT2SEC_SHD: calculates the absolute time in sec from sac header structure
%--------------------------------------------------------------------------
% Usage: [ abstime ] = gmt2sec_SHD( sachd )
%--------------------------------------------------------------------------
% Inputs:
%   sachd: a structure of sac header;
%   tmarker: time marker to calculate the absolute seconds
%--------------------------------------------------------------------------
% Outputs:
%   abstime: absolute time in seconds, with reference zero time: 2000-001_00:00:00
%--------------------------------------------------------------------------
% Notes:
%   Nov 8, 2011: created
%--------------------------------------------------------------------------

%%
reftime = eval(['sachd.',tmarker]);
abstime = yjd2sec(sachd.nzyear,sachd.nzjday,sachd.nzhour,sachd.nzmin,sachd.nzsec+sachd.nzmsec/1000)+reftime;
end
