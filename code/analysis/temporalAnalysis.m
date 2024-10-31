function [sw_duration, fw_duration, fw_delay] = temporalAnalysis(...
    swave, fwave, Fs, win_split)
%TEMPORALANALYSIS Computes the temportal metrics of the analysis. The
%duration of the event in each channel for the fast and slow waves is
%computed as well as the delay between the initiation of the slow and the
%fast waves.
%
%   Input:
%    - swave, slow-wave component of the signals to analyse, 
%    swave(NB_SAMPLES x CHANNELS).
%    - fwave, fast-wave component of the signals to analyse, 
%    swave(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - win_split, percentage of the window before the event timestamp used
%    to find the peak closest to the mark.
%
%   Return:
%    - sw_duration, duration of the slow-wave component of the event for
%    each channel, sw_duration(1 x CHANNELS).
%    - fw_duration, duration of the fast-wave component of the event for
%    each channel. Channel that do not exhibt bursting contain NaN values,
%    fw_duration(1 x CHANNELS).
%    - fw_delay, delay between the start of the slow-wave and the start of
%    the fast-wave, fw_delay(1 x CHANNELS).
if size(swave) ~= size(fwave)
    % Check that sizes are the same
    error('Error: the slow and fast wave component should have equal sizes');
end

[sw_duration, sw_start_times, ~] = computeDuration(swave, Fs, ...
    win_split);
[fw_duration, fw_start_times, ~] = computeDuration(fwave, Fs, ...
    win_split, 'burst');
fw_delay = fw_start_times - sw_start_times;
end