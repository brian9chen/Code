function [ sac_st_cell ] = SAC_freadlist( saclist, prefix, suffix)
% SAC_readlist: read sac files from a list
%--------------------------------------------------------------------------
% Usage: [ sac_st_cell ] = SAC_readlist( saclist, prefix, suffix)
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
    fn_sac = [prefix,sacnm,suffix];
    sac_st_cell{i} = SAC_fread(fn_sac);
%     sac_st(i) = SAC_fread(fn_sac);
end

end