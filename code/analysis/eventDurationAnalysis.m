function [event_duration_mean, event_duration_std] = ...
    eventDurationAnalysis(signal, Fs, time_res, tolerance)
%EVENTDURATIONANALYSIS Computes the mean duration and standard deviation of
%the event in the given signals. This method uses the spectrogram to
%determine which areas in the signal have a higher power associated with an
%event.
%
%   Input:
%    - signal, signals to analyse, signal(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - time_res, temporal resolution for the spectrogram.
%    - tolerance, maximum distance between events for combining, in
%    elements.
%
%   Return:
%    - event_duration_mean, mean duration of the event in seconds.
%    - event_duration_mean, standard deviation of the duration of the event
%       in seconds.
nb_chns = size(signal, 2);
event_duration = zeros(1, nb_chns);

for j = 1:nb_chns
    [pow, ~, t] = pspectrum(signal(:, j), Fs, 'spectrogram', ...
        'TimeResolution', time_res); % Get power
    power_sum = sum(pow);
    idx = power_sum >= median(power_sum);

    connections = bwconncomp(idx);
    connected_idx = connections.PixelIdxList;

    % Find the length of each connected component
    connection_len = cellfun(@numel, connected_idx);

    % Find the index of the two longest sequences
    [~, idx] = maxk(connection_len, 2);

    event_idx = connected_idx{idx(1)}; % Default to longest event

    if abs(diff(idx)) == 1
        % Check to see if two events shouldn't be combined
        combined_event_idx = vertcat(connected_idx{idx});
        combined_event_idx = sort(combined_event_idx); 

        if max(diff(combined_event_idx)) <= tolerance
            % Use the combined event indices instead
            event_idx = combined_event_idx;
        end
    end

    event_duration(j) = t(event_idx(end)) - t(event_idx(1));

end

event_duration_mean = mean(event_duration);
event_duration_std = std(event_duration);
end