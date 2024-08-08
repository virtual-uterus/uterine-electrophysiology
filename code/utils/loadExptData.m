function [data, tvec, Fs, electrode_cnfg, marks, electrode_dist] = ...
    loadExptData(mat_file, start_time, end_time)
%LOADEXPTDATA Loads the experimental data from the mat file.
%
% The signals are cropped to start at start_time and end at end_time. The
% signals will be end_time - start_time seconds long. The time vector tvec
% is also cropped to fit the signal length.
%
%   Input:
%    - mat_file, path to the mat file containing the data.
%    - start_time, analysis start time (in s).
%    - end_time, analysis end time (in s).
%
%   Return:
%    - data, data read from the mat file, data(NB_SAMPLES x CHANNELS).
%    - tvec, time vector of the experiment.
%    - Fs, sampling frequency.
%    - electrode_cnfg, electrode configuration.
%    - marks, marks cell (if exists).
%    - electrode_dist, distance between electrodes (in mm). 
load(mat_file, 'toapp');

data = toapp.filtdata'; % Load data and flip to match NB_SAMPLES x CHANNELS
tvec = toapp.tvec;
Fs = toapp.fs;
electrode_cnfg = toapp.orientedElec;
electrode_dist = toapp.elecSpacing;

marks = {};

if isfield(toapp, 'TimeAmplCluster')
    % Check if data has marks
    marks = toapp.TimeAmplCluster;
end

data = data(start_time*Fs:end_time*Fs, :); % Crop signal to correct time
tvec = tvec(start_time*Fs:end_time*Fs);
end