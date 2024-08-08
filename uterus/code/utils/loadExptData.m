function [data, tvec, Fs, electrode_cnfg, vargout] = loadExptData( ...
    mat_file, x_sec)
%LOADEXPTDATA Loads the experimental data from the mat file.
%
% x_sec from the start and end of the signals are removed.
%
%   Input:
%    - mat_file, path to the mat file containing the data.
%    - x_sec, number of seconds to remove from beginning and end of signal,
%   default value 5.
%
%   Return:
%    - data, data read from the mat file, data(NB_SAMPLES x CHANNELS).
%    - tvec, time vector of the experiment.
%    - Fs, sampling frequency.
%    - electrode_cnfg, electrode configuration.
%    - vargout, marks cell (if exists).
if nargin < 2
    x_sec = 5;
end

load(mat_file, 'toapp');

data = toapp.filtdata'; % Load data and flip to match NB_SAMPLES x CHANNELS
tvec = toapp.tvec;
Fs = toapp.fs;
electrode_cnfg = toapp.orientedElec;

if isfield(toapp, 'TimeAmplCluster')
    % Check if data has marks
    vargout = toapp.TimeAmplCluster;
end

data = data(x_sec*Fs:end-x_sec*Fs, :); % Remove x_sec before and after
tvec = tvec(x_sec*Fs:end-x_sec*Fs);
end