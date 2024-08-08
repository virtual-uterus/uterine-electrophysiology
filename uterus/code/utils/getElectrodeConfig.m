function electrode_cnfg = getElectrodeConfig(cnfg_file)
%GETELECTRODECONFIG Returns the configuration of the electrode arrays
%
%   Only works with 32 element arrays (G7)
%
%   Input:
%    - cnfg_file, path to the configuration file.
%
%   Return:
%    - electrode_cnfg, matrix of the electrode configuration.
cnfg_data = importdata(cnfg_file);
electrode_cnfg = cnfg_data.data;
electrode_cnfg = electrode_cnfg(2:end, :); % Remove first line

if size(electrode_cnfg, 1) > 32
    % Using more than 2 G7 arrays
    electrode_cnfg(3:3:end, :) = []; % Remove every third row
    electrode_cnfg = reshape(electrode_cnfg', [8, 16])';
end
end