function [ secondnum ] = SAC_gmt2sec( sac_st, tmarker )
%--------------------------------------------------------------------------
% SAC_gmt2sec: calculates the total number of seconds of the time marker in sac header
%--------------------------------------------------------------------------
% Usage: [ secondnum ] = SAC_gmt2sec( sac_st, tmarker )
%--------------------------------------------------------------------------
% Inputs:
%   sac_st: a structure of sac header;
%   tmarker: time marker to calculate the absolute seconds
%--------------------------------------------------------------------------
% Outputs:
%   secondnum: number of seconds, zero is set to: 2000-001_00:00:00
%--------------------------------------------------------------------------
% Notes:
%   Nov 8, 2011: created;
%   2011-12-16: modified, add time marker for 'gmt';
%--------------------------------------------------------------------------

%%

if strcmp(tmarker,'gmt')
    ref_time = 0;
else
    ref_time = eval(['sac_st.',tmarker]);
end

secondnum = yjd2sec(sac_st.nzyear,sac_st.nzjday,sac_st.nzhour,sac_st.nzmin,sac_st.nzsec+sac_st.nzmsec/1000)+ref_time;

end