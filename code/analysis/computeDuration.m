function [event_duration, start_times, end_times] = ...
    computeDuration(signal, Fs, conn_thresh, sample_percent, type)
%COMPUTEDURATION Computes the duration of the event in each channel.
%This method uses a thresholding technique based on the average value of
%the absolute signal. The type is used to run the burst detection
%algorithm.
%
%   Input:
%    - signal, signals to analyse, signal(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - conn_thresh, connection threshold used to determine if detected
%    events should be fused or not. 
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
    % Find events using the trend of the signal
    trend = trenddecomp(abs(signal(:, j)), 'ssa', ...
        round(nb_samples*sample_percent));

    if strcmp(type, 'burst')
        % If looking at bursts isolate signals with bursts using variance
        if var(trend) <= 5
            continue
        end
    end
    
    % Detect using a combination of thresholding and peak detection
    idx = trend >= mean(trend); % Thresholding

    % Find peaks and ensure the indices are in a valid range
    [~, peak_loc, peak_width] = findpeaks(trend, ...
        'MinPeakHeight', mean(trend), 'WidthReference', 'halfheight');
    peak_min_max = [round(peak_loc - (peak_width /2)), ...
        round(peak_loc + (peak_width / 2))];
    peak_min_max(peak_min_max <= 0) = 1; 
    peak_min_max(peak_min_max > nb_samples) = nb_samples; 

    for k = 1:size(peak_loc, 1)
        idx(peak_min_max(k, 1):peak_min_max(k, 2)) = 1;
    end

    % Correct errors 
    conn_idx = movmean(idx, round(0.05*nb_samples)) >= conn_thresh;
    connections = bwconncomp(conn_idx);
    connected_idx = connections.PixelIdxList;

    % Find the length of each connected component
    connection_len = cellfun(@numel, connected_idx);

    % Find the index of the longest sequences
    [~, max_idx] = max(connection_len);

    event_idx = connected_idx{max_idx(1)}; % Default to longest event

    start_times(j) = event_idx(1) / Fs;
    end_times(j) = event_idx(end) / Fs;
end

event_duration = end_times - start_times;
end