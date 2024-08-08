function reshaped_data = reshapeData(data, electrode_cnfg)
%RESHAPEDATA Reshapes the data to fit the electrode configuration. The data
%is normalised at the same time as it is being reshaped.
%
%   Input:
%    - data, data read from the mat file, data(NB_SAMPLES x CHANNELS).
%    - electrode_cnfg, electrode configuration.
%
%   Return:
%    - reshaped_data, reshaped data based on the electrode configuration,
%       data(NB_SAMPLES x NB_ROWS x NB_COLS).
reshaped_data = zeros( ...
    size(data, 1), ...
    size(electrode_cnfg, 1), ...
    size(electrode_cnfg, 2));

for j = 1:size(data, 2)
    [l, m] = ind2sub(size(electrode_cnfg), j);
    reshaped_data(:, l, m) = data(:, j) ./ abs(max(abs(data(:, j))));
end
end