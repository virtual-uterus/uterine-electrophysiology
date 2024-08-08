function markedDataAnalysis(dir_path, base_name)
%MARKEDDATAANALYSIS Performs the frequency analysis on the input data on
%marked data exported from UGEMS. 
%
%   base_dir is $HOME/Documents/phd/ and set in utils/baseDir()
%
%   Input:
%    - dir_path, path to the directory containing the dataset from base_dir
%    - base_name, name of the dataset.
%   
%   Return: 
%% Load data and parameters
load_directory = join([baseDir(), dir_path, base_name, 'mat'], '/');
config_file_path = join([load_directory, base_name + '_config.toml'], '/');

% Get params from toml file
toml_map = toml.read(config_file_path);
params = toml.map_to_struct(toml_map);

% Create the name of the mat file to analyse
mat_file_name = join([base_name, "run", num2str(params.run_nb), ...
    "G7x2_marked.mat"], '_');
mat_file_path = join([load_directory, mat_file_name], '/');

% Load data
[data, tvec, Fs, ~, marks] = loadExptData(mat_file_path);

close all; % Close the UGEMS window

win_size = double(params.half_win_size .* Fs);
nb_points = length(tvec); % Number of sampling points

%% Determine the event occurence rate
nb_marks = length(marks);
[~, event_idx] = find(cellfun('length', marks) > params.min_nb_chns);

% Remove unlabeled marks if the have been extracted in the index list
if event_idx(end) == nb_marks
    event_idx = event_idx(1:end-1);
end

nb_events = length(event_idx);
EOR = nb_events ./ (tvec(end) - tvec(1)); % Event occurence rate
disp(['Event occurence rate is ', num2str(EOR),  ' Hz']);

%% Frequency analysis on events
for k = event_idx
    disp(['Processing event number ', num2str(k)])
    event_data = marks{k}(:, 3:4); % Get timestamp and chn

    if length(event_data) > params.min_nb_chns
        start_times = round(event_data(:, 1) .* Fs) - win_size;
        end_times = round(event_data(:, 1) .* Fs) + win_size;

        % Ensure start and end times are valid
        start_times(start_times <= 0) = 1; % Reset to 1 if negative or 0
        end_times(end_times > nb_points) = nb_points; % Reset to be end time

        events = data(start_times:end_times, event_data(:, 2));
        [fwave, swave] = separateWaves(events, ...
            params.highpass_cutoff_freq, ...
            params.lowpass_cutoff_freq, ...
            Fs);

        % Perform analyse on slow-wave and fast-wave components
        [sw_mean, sw_std] = frequencyAnalysis(swave, Fs);
        [fw_mean_bw, fw_std_bw, ~, ~, ~, ~] = frequencyAnalysis(fwave, ...
            Fs, 'power');

        % Display results
        disp(['    Slow-wave max frequency: ', ...
            num2str(sw_mean), ' ± ', num2str(sw_std), ' Hz'])
        disp(['    Fast-wave 95% power frequency band: ', ...
            num2str(fw_mean_bw), ' ± ', num2str(fw_std_bw), ' Hz'])
    else
        % Skip if not enough points
        disp(['    Only ', num2str(length(event_data)), ...
            ' events: skipping analysis'])
    end
end
end