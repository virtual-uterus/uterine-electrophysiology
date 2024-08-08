function vel = computeVelocity(event_data, electrode_cnfg, electrode_dist)
%COMPUTEVELOCITY Computes an estimate of the propagation velocity by 
%looking at the distance between the lowest and highest timestamps.
%
%   Input:
%    - event_data, array containing time stamps (first column) and
%    electrode numbers (second column), event_data(CHANNELS x 2).
%    - electrode_cnfg, electrode arrangement, electrode_cnfg(16 x 4).
%    - electrode_dist, distance between electrodes.
%
%   Return:
%    - vel, propagation velocity based on time it takes to travel between
%    the electrodes associated with the highest and lowest timestamps.
[max_time, max_idx] = max(event_data(:, 1)); % Get highest time
[min_time, min_idx] = min(event_data(:, 1)); % Get lowest time
[min_x, min_y] = find(electrode_cnfg == event_data(min_idx, 2));
[max_x, max_y] = find(electrode_cnfg == event_data(max_idx, 2));

% Calculate distance between electrodes
dist = pdist2([min_x, min_y], [max_x, max_y]) * electrode_dist;
time_delta = max_time - min_time;
vel = dist / time_delta; 
end