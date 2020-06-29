function [ year,jday,hour,min,sec ] = sec2yjd( abstime )
%sec2yjd converts from absolute time in second to year,jday,hour,min,sec
% Usage: [ year,jday,hour,min,sec ] = sec2yjd( abstime )
% note:
%	1. the absolute zero time is 2000-001_00:00:00
% created on Oct. 14, 2011

%%
Nsec_1day = 3600*24;
%
Nday2000 = datenum(2000,1,1);
[year, month, day, hour, min, sec] = datevec(abstime/Nsec_1day+Nday2000);
jday = juliandate(year,month,day)-juliandate(year,1,1)+1;
end

