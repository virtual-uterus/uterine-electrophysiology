function [sw_duration, fw_duration, fw_delay] = temporalAnalysis(...
    swave, fwave, Fs, conn_thresh, sample_percent)
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
%    - conn_thresh, connection threshold used to determine if detected
%    events should be fused or not. 
%    - sample_percent, percentage of NB_SAMPLES to use for window in the
%    error correction and the number of RMS samples for the envelope.
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
    conn_thresh, sample_percent);
[fw_duration, fw_start_times, ~] = computeDuration(fwave, Fs, ...
    conn_thresh, sample_percent, 'burst');
fw_delay = fw_start_times - sw_start_times;
end