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
mean_time = mean(arranged_times, 2, 'omitnan');

%% Estimate propagation direction based on the trend of the mean tiems
propagation_trend = trenddecomp(mean_time, 'ssa', 4);
% [~, cnt] = zerocrossrate(diff(propagation_trend), 'Method', 'comparison');

[~, min_ind] = min(propagation_trend);
[~, max_ind] = max(propagation_trend);

if abs(max_ind - min_ind) < 10
    prop_direction = 0; % Disorganised activity

else
    if min_ind <= max_ind
        prop_direction = 1; % Ovaries to cervix

    else
        prop_direction = -1; % Cervix to ovaries
    end
end

%% Estimate propagation distance based on the mean times
[~, min_ind] = min(mean_time);
[~, max_ind] = max(mean_time);
prop_dist = abs(electrode_dist * (max_ind - min_ind));

%% Estimate propagation velocity using UTEMS code
[~, ~, prop_vel] = calcVelocity(arranged_times, electrode_dist);
end