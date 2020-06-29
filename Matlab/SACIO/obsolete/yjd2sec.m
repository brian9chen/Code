function [ abstime ] = yjd2sec( year,jday,hour,min,sec )
%CAL_ABSTIME calculate absolute time in second reffered to 2000-001_00:00:00
% Usage: [ abstime ] = cal_abstime( year,jday,hh,mm,ss )
% created on Oct. 14, 2011

%%
Nsec_1day = 3600*24;
Nsec_1hour = 3600;
Nsec_1min = 60;

% datenum(2000,1,*1*): *1* must be used
abstime = (datenum(year,1,0)+jday-datenum(2000,1,1))*Nsec_1day+hour*Nsec_1hour+min*Nsec_1min+sec;
end

