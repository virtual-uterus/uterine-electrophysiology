function [event_duration, start_times, end_times] = ...
    computeDuration(signal, Fs, win_split, type)
%COMPUTEDURATION Computes the duration of the event in each channel.
%The type is used to run the burst detection algorithm.
%
%   Input:
%    - signal, signals to analyse, signal(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - win_split, percentage of the window before the event timestamp used
%    to find the peak closest to the mark.
%    - type, str {'burst', 'swave'}, type of signal to process, default
%    value is swave.

%   Return:
%    - event_duration, duration of the event in seconds in each channel,
%       event_duration(1 x CHANNELS).
%    - start_times, start time of the event in seconds in each channel,
%       start_times(1 x CHANNELS).
%    - end_times, end time of the event in seconds in each channel,
%       end_times(1 x CHANNELS).
if nargin < 4
    type = 'swave';
end

[nb_samples, nb_chns] = size(signal);
chns = 1:nb_chns; % Channel list to iterate through
sample_percent = 0.12; 

% Placeholders for outputs
start_times = nan(1, nb_chns);
end_times = nan(1, nb_chns);

for j = chns
    if strcmp(type, 'burst')
        % Find events using the trend of the abs of the signal 
        trend = trenddecomp(abs(signal(:, j)), 'ssa', ...
            round(nb_samples*sample_percent));
        % Normalise trend
        trend = trend ./ max(trend);

        % If looking at bursts isolate signals with bursts using variance
        if var(trend) <= 0.03
            continue
        end

        % Find peaks and ensure the indices are in a valid range
        [~, peak_loc] = findpeaks(trend);

        if ~isempty(peak_loc)
            % If peaks have been found estimate duration
            % Find peak closest to timestamp
            [~, idx] = min(abs(peak_loc - round(win_split*length(trend))));
            peak_idx = peak_loc(idx);

            bin_trend = imbinarize(trend);

            % Check if the value at peak_idx in bin_trend is 1
            if bin_trend(peak_idx) == 1
                % Find the start of the connected 1s region
                first_idx = find( ...
                    bin_trend(1:peak_idx) == 0, 1, 'last') + 1;
                if isempty(first_idx)
                    first_idx = 1; % If no 0s, default to beginning
                end

                % Find the end of the connected 1s region
                end_idx = find( ...
                    bin_trend(peak_idx:end) == 0, 1, 'first') + peak_idx - 2;
                if isempty(end_idx)
                    end_idx = length(bin_trend); % If no 0s, default to end
                end

                start_times(j) = first_idx;
                end_times(j) = end_idx;
            end
        end

    else % If slow-waves
        % Find events using the trend of the signal
        trend = trenddecomp(signal(:, j), 'ssa', ...
            round(nb_samples*sample_percent));

        % Find peaks and ensure the indices are in a valid range
        [~, peak_loc] = findpeaks(trend);

        if ~isempty(peak_loc)
            % If peaks have been found estimate duration
            % Find peak closest to timestamp
            [~, idx] = min(abs(peak_loc - round(win_split*length(trend))));
            peak_idx = peak_loc(idx);
            grad = gradient(trend);
            [~, ~, crossing_idx] = zerocrossrate(grad);
            crossing_idx = find(crossing_idx);

            % Start index is first direction change before peak
            [~, start_idx] = min(abs(crossing_idx - peak_idx));
            if start_idx == 1
                start_idx = 2; % Default to 2 to avoid error
            end
            start_times(j) = crossing_idx(start_idx-1);

            % Second 0 cross after peak in gradient is return to baseline
            if length(crossing_idx) >= start_idx + 2
                end_idx = crossing_idx(start_idx + 2);
            elseif length(crossing_idx) >= start_idx + 1
                end_idx = crossing_idx(start_idx + 1); % Underestimate duration
            else
                end_idx = nb_samples; % Default to window edge
            end

            end_times(j) = end_idx;
        end
    end
end

% Convert into seconds and find duration
start_times = start_times ./ Fs;
end_times = end_times ./ Fs;
event_duration = end_times - start_times;
end