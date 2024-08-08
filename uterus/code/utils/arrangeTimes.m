function arranged_times = arrangeTimes(event_data, electrode_cnfg)
%ARRANGETIMES Reshapes the timestamps of event_data to fit the electrode
%configuration matrix. If there is no value for a certain electrode, it is
%replaced with NaN.
%
%   Input:
%    - event_data, array containing timestamps (first column) and
%    electrode numbers (second column), event_data(CHANNELS x 2).
%    - electrode_cnfg, electrode arrangement, electrode_cnfg(16 x 4).
%
%   Return:
%    - arranged_times, matrix of same shape as electrode_cnfg with the
%       timestamps.
arranged_times = nan(size(electrode_cnfg));

if max(electrode_cnfg) > 64
    % Reset electrode number if using C and D channels
    electrode_cnfg = electrode_cnfg - 64;
end

for j = 1:size(event_data, 1)
    idx = electrode_cnfg == event_data(j, 2);
    arranged_times(idx) = event_data(j, 1);
end
end