function [event_interval_mean, event_interval_std, nb_samples] = ...
    eventIntervalAnalysis(past_event, cur_event)
%EVENTINTERVALANALYSIS Computes the mean interval and standard deviation of
%two events based on their timestamps.
%
%   Input:
%    - past_event, timestamps and channel numbers of the first event.
%    - cur_event, timestamps and channel numbers of the following event.
%
%   Return:
%    - event_interval_mean, mean interval between the two events (s).
%    - event_interval_mean, standard deviation of interval between the two
%    events (s).
%   - nb_samples, number of common channels for calculating average std
%   later.
nb_common_chns = intersect(past_event(:, 2), cur_event(:, 2))';
event_interval = zeros(size(nb_common_chns));
nb_samples = length(nb_common_chns);

for j = 1:length(nb_common_chns)
    chn_nb = nb_common_chns(j);
    cur_idx = cur_event(:, 2) == chn_nb;
    past_idx = past_event(:, 2) == chn_nb;
    event_interval(j) = abs( ...
        past_event(past_idx, 1) - cur_event(cur_idx, 1));
end

event_interval_mean = mean(event_interval);
event_interval_std = std(event_interval);
end