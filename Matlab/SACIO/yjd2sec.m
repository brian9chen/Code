function [ secondnum ] = yjd2sec( year,jday,hour,min,sec )
% yjd2sec calculates the total number of seconds from the input ( year,jday,hour,min,sec )
%--------------------------------------------------------------------------
% Usage: [ secondnum ] = yjd2sec( year,jday,hour,min,sec )
%--------------------------------------------------------------------------
% Input:
%   year,jday,hour,min,sec: time vector
%--------------------------------------------------------------------------
% Output:
%   secondnum: number of seconds, zero is set to: 2000-001_00:00:00
%--------------------------------------------------------------------------
% Notes
%   Oct. 14, 2011: created
%   2011-12-17: modified
%--------------------------------------------------------------------------

%%
Nsec_1day = 3600*24;
Nsec_1hour = 3600;
Nsec_1min = 60;

% datenum(2000,1,*1*): *1* must be used
secondnum = (datenum(year,1,0)+jday-datenum(2000,1,1))*Nsec_1day+hour*Nsec_1hour+min*Nsec_1min+sec;
end