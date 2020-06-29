function [ year,jday,hour,min,sec ] = sec2yjd( secondnum )
% sec2yjd converts second number to (year,jday,hour,min,sec)
%--------------------------------------------------------------------------
% Usage: [ year,jday,hour,min,sec ] = sec2yjd( secondnum )
%--------------------------------------------------------------------------
% Input
%   secondnum: number of seconds, zero is set to: 2000-001_00:00:00
%--------------------------------------------------------------------------
% Output
%   year,jday,hour,min,sec: time vector
%--------------------------------------------------------------------------
% Note:
%   Oct. 14, 2011: created
%   2011-12-17: modified
%--------------------------------------------------------------------------

%%
Nsec_1day = 3600*24;

Nday2000 = datenum(2000,1,1);
[year, month, day, hour, min, sec] = datevec(secondnum/Nsec_1day+Nday2000);
jday = juliandate(year,month,day)-juliandate(year,1,1)+1;

end