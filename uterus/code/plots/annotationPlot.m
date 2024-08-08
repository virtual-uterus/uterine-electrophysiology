function annotationPlot(dir_path, base_name)
%ANNOTATIONPLOT Calculates the energy of the average signal column-wise and
%determines the position of possible events. This function is used to
%inform the annotation of the data by giving approximate location of
%events for UGEMS.
%
%   base_dir is $HOME/Documents/phd/ and set in utils/baseDir()
%
%   Input:
%    - dir_path, path to the directory containing the dataset from base_dir
%    - base_name, name of the dataset.
%   
%   Return:  
load_directory = join([baseDir(), dir_path, base_name, 'mat'], '/');
config_file_path = join([load_directory, base_name + '_config.toml'], '/');

% Get params from toml file
toml_map = toml.read(config_file_path);
params = toml.map_to_struct(toml_map);

% Create the name of the mat file to analyse
mat_file_name = join([base_name, "run", num2str(params.run_nb), ...
    "G7x2_no_marks.mat"], '_');
mat_file_path = join([load_directory, mat_file_name], '/');

% Load data
[data, ~, Fs, electrode_cnfg, ~] = loadExptData(mat_file_path);

close all; % Close the UGEMS window

reshaped_data = reshapeData(data, electrode_cnfg);

figure;
tiledlayout(4, 1);

for j = 1:4
    nexttile
    [pow, ~, t] = pspectrum(squeeze(mean(reshaped_data(:, j), 2)), Fs, ...
        'spectrogram', 'TimeResolution', params.time_res);
    mean_pow = mean(pow);
    [pks, locs] = findpeaks(mean_pow, 'MinPeakHeight', mean(mean_pow), ...
        'MinPeakDistance', params.min_peak_dist);
    plot(t, mean(pow), 'k'); hold on; plot(t(locs), pks, 'r*');
    hold off;
end

