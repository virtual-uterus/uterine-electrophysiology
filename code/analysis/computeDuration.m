function [event_duration, start_times, end_times] = ...
    computeDuration(signal, Fs, win_split, sample_percent, type)
%COMPUTEDURATION Computes the duration of the event in each channel.
%This method uses a thresholding technique based on the average value of
%the absolute signal. The type is used to run the burst detection
%algorithm.
%
%   Input:
%    - signal, signals to analyse, signal(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - win_split, percentage of the window before the event timestamp used
%    to find the peak closest to the mark.
%    - sample_percent, percentage of NB_SAMPLES to use for window in the
%    error correction and the number of RMS samples for the envelope.
%    - type, str {'burst', 'swave'}, type of signal to process, default
%    value is swave.

%   Return:
%    - event_duration, duration of the event in seconds in each channel,
%       event_duration(1 x CHANNELS).
%    - start_times, start time of the event in seconds in each channel,
%       start_times(1 x CHANNELS).
%    - end_times, end time of the event in seconds in each channel,
%       end_times(1 x CHANNELS).
if nargin < 5
    type = 'swave';
end

[nb_samples, nb_chns] = size(signal);
chns = 1:nb_chns; % Channel list to iterate through

% Placeholders for outputs
start_times = nan(1, nb_chns);
end_times = nan(1, nb_chns);

for j = chns
    if strcmp(type, 'burst')
        % Find events using the trend of the abs of the signal 
        trend = trenddecomp(abs(signal(:, j)), 'ssa', ...
            round(nb_samples*sample_percent));
        % If looking at bursts isolate signals with bursts using variance
        if var(trend) <= 5
            continue
        end
    
    else
        % Find events using the trend of the signal
        trend = trenddecomp(signal(:, j), 'ssa', ...
            round(nb_samples*sample_percent));
    end

    % Find peaks and ensure the indices are in a valid range
    [~, peak_loc, peak_width] = findpeaks(trend);

    if ~isempty(peak_loc)
        % If peaks have been found estimate duration
        peak_min_max = [round(peak_loc - (peak_width /2)), ...
            round(peak_loc + (peak_width / 2))];
        peak_min_max(peak_min_max <= 0) = 1;
        peak_min_max(peak_min_max > nb_samples) = nb_samples;

        % Find peak closest to timestamp
        [~, idx] = min(abs(peak_loc - round(win_split*length(trend))));

        start_times(j) = peak_min_max(idx, 1); % Start of closest peak

        % Find the end of the event by finding index where it crosses mean
        [~, ~, crossing_idx] = zerocrossrate(trend, Level=mean(trend));
        end_idx = find(crossing_idx(peak_min_max(idx, 2)) > 0);

        if length(end_idx) < 2
            end_times(j) = length(trend); % Event goes until end of window

        else
            end_times(j) = crossing_idx( ...
                peak_min_max(idx, 2)) + end_idx(2) - 1;
        end
    end
end

% Convert into seconds and find duration
start_times = start_times ./ Fs;
end_times = end_times ./ Fs;
event_duration = end_times - start_times;
end