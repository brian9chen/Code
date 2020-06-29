function [ sac_st_cell ] = rdSAClist( saclist, prefix, suffix)
% rdSAClist: read sac files from a list
%--------------------------------------------------------------------------
% Usage: [ sac_st_cell ] = rdSAClist( saclist, prefix, suffix)
%--------------------------------------------------------------------------
% Inputs:
%   saclist: the list of sac file names;
%   prefix: used for parent directory;
%   suffix: used for file extension;
%--------------------------------------------------------------------------
% Outputs:
%   sac_st_cell: cell of sac structure
%--------------------------------------------------------------------------
% Notes:
%   Nov 11, 2011: created
%   2011-12-16: modified
%--------------------------------------------------------------------------

%% read in station list

fid = fopen(saclist,'r');
saclist_cell = textscan(fid,'%s');
fclose(fid);
%
sacnm_cell = saclist_cell{1};
Nsac = length(sacnm_cell);

%% read in sac files

sac_st_cell = cell(Nsac,1);
for i = 1:Nsac
    sacnm = sacnm_cell{i};
    fp_sac = [prefix,sacnm,suffix];
    sac_st_cell{i} = rdsac(fp_sac);
end

end