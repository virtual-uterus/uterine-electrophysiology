function [prop_dist, prop_vel, prop_direction] = propagationAnalysis( ...
    arranged_times, electrode_dist)
%PROPAGATIONANALYSIS Computes the propagation metrics based on the arranged
%timestamps of the event and the inter-electrode distance.
%
%   Inputs:
%    - arranged_times, timestamps of the event arranged according to the
%    electrode configuration, arranged_times(M x N).
%    - electrode_dist, inter-electrode distance, in mm.
%
%   Return:
%    - prop_dist, distance between the latest and earliest timestamps using
%       the mean timestamps and not the trend, in mm.
%    - prop_vel, propagation velocity at each electrode using UTEMS code,
%       prop_vel(M x N).
%    - prop_direction, propagation direction based on the trend of the mean
%       timestamps, 1 ovaries -> cervix, -1 cervix -> ovaries, 0
%       disorganised activity.
[nb_rows, nb_cols] = size(arranged_times);
prop_trends = zeros(nb_rows, nb_cols);
prop_directions = ones(1, nb_cols); % Default direction ovaries to cervix
mean_time = mean(arranged_times, 2, 'omitnan');

%% Estimate propagation direction based on the trend of the mean times
for k = 1:nb_cols
    prop_trends(:, k) = trenddecomp(arranged_times(:, k));
end

[~, min_ind] = min(prop_trends);
[~, max_ind] = max(prop_trends);

prop_directions(abs(max_ind - min_ind) < round(...
    0.8 * size(arranged_times, 1))) = 0; % Disorganised activity

prop_directions(min_ind > max_ind) = -1; % Cervix to ovaries

[grp_size, vals] = groupcounts(prop_directions');
[max_val, max_idx] = max(grp_size); 

if max_val < 3
    prop_direction = 0; % Several directions = disorganised

else
    prop_direction = vals(max_idx); 
end

%% Estimate propagation distance based on the mean times
[~, min_ind] = min(mean_time);
[~, max_ind] = max(mean_time);
prop_dist = abs(electrode_dist * (max_ind - min_ind));

%% Estimate propagation velocity using UTEMS code
[~, ~, prop_vel] = calcVelocity(arranged_times, electrode_dist);
end