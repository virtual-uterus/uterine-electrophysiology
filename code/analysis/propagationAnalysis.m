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
%       other direction.
mean_time = mean(arranged_times, 2, 'omitnan');

%% Estimate propagation distance based on the mean times
[~, min_ind] = min(mean_time);
[~, max_ind] = max(mean_time);
prop_dist = abs(electrode_dist * (max_ind - min_ind));

%% Estimate propagation velocity and direction using UTEMS code
[~, Vy, prop_vel] = calcVelocity(arranged_times, electrode_dist);

% Remove values that are not from marked channels
nan_chns = find(isnan(arranged_times));
Vy(nan_chns) = nan;
prop_vel(nan_chns) = nan;
Vy_mean = mean(Vy, 'omitnan');
Vy_mean(isnan(Vy_mean)) = [];  % In case a column has no marks

Vy_mean_signs = sign(Vy_mean);
if any(sum(Vy(:, Vy_mean_signs > 0) < 0) > 5) || any(sum(Vy(:, Vy_mean_signs < 0) > 0) > 5)
    prop_direction = 0;
elseif not(xor(any(Vy_mean > 0), all(Vy_mean > 0)))
    prop_direction = sign(Vy_mean(1));
else
    prop_direction = 0;
end