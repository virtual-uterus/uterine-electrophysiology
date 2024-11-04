% Script to produce signals for the component duration figure
% Last modified: Nov 2024
% Author Mathias Roesler
%% Load data and parameters
dir_path = "electrophys/data";
save_path = "electrophys/figures/signals";
base_name = "AWB003";

load_directory = join([baseDir(), dir_path, base_name, 'mat'], '/');
config_file_path = join([load_directory, base_name + '_config.toml'], '/');
save_directory = join([baseDir(), save_path], '/');

% Get params from toml file
toml_map = toml.read(config_file_path);
params = toml.map_to_struct(toml_map);

% Create the name of the mat file to analyse
mat_file_name = join([base_name, "run", num2str(params.run_nb), ...
    "G7x2_marked.mat"], '_');
mat_file_path = join([load_directory, mat_file_name], '/');

% Load data
load(mat_file_path, 'toapp');
close all; % Close window

data = toapp.filtdata'; % Load data and flip to match NB_SAMPLES x CHANNELS
tvec = toapp.tvec;
Fs = toapp.fs;
electrode_cnfg = toapp.orientedElec;

% Define some constants
start_val = 215*Fs;
end_val = 255*Fs;
chn_nb = 52;
sample_percent = 0.08; 

if min(electrode_cnfg, [], "all") == 65
    % Reset electrode numbers if using C and D channels
    electrode_cnfg = electrode_cnfg - 64;
end

% Extract components
[fwave, swave] = separateWaves(data, ...
    params.highpass_cutoff_freq, ...
    params.lowpass_cutoff_freq, ...
    Fs);

% Normalise data
norm_fwave = fwave(start_val:end_val, chn_nb) ./ max( ...
    abs(fwave(start_val:end_val, chn_nb)));
norm_swave = swave(start_val:end_val, chn_nb) ./ max( ...
    abs(swave(start_val:end_val, chn_nb)));

components = ["low_frequency_event", "high_frequency_event"];
all_data = [norm_swave norm_fwave];

%% Plot single event components
for k = 1:2
    figure; % Create a new figure    
    y_axis = all_data(:, k);

    plot(tvec(start_val:end_val), y_axis, 'k', 'LineWidth', 1.5);
    ylabel("Normalised amplitude");
    xlabel("Time (s)");

    set(gca, 'XTickLabel', 0:5:40); % Set x-axis labels

    % Save figure and close it
    fig = gcf;
    exportgraphics(fig, strcat(save_directory, '/', components(k), ...
        ".png"), 'Resolution',300)
    close all;
end

components = ["low_frequency_trend", "high_frequency_trend"];

%% Plot single event slow-wave trend
    figure; % Create a new figure    
    y_axis = all_data(:, 1);
    trend = trenddecomp(y_axis, 'ssa', ...
        round(length(y_axis)*sample_percent));
    trend = trend ./ max(abs(trend));

    plot(tvec(start_val:end_val), trend, 'k', 'LineWidth', 1.5);
    ylabel("Normalised amplitude");
    xlabel("Time (s)");

    set(gca, 'XTickLabel', 0:5:40); % Set x-axis labels

    % Save figure and close it
    fig = gcf;
    exportgraphics(fig, strcat(save_directory, '/', components(k), ...
        ".png"), 'Resolution',300)
    close all;

%% Plot single event burst composition
    figure; % Create a new figure    
    y_axis = all_data(:, 2);
    trend = trenddecomp(abs(y_axis), 'ssa', ...
        round(length(y_axis)*sample_percent));
    trend = trend ./ max(abs(trend));
    bin_trend = imbinarize(trend); 

    plot(tvec(start_val:end_val), y_axis, 'k', 'LineWidth', 1.5);
    hold on;
    plot(tvec(start_val:end_val), trend, 'r', 'LineWidth', 1.5);
    plot(tvec(start_val:end_val), bin_trend, 'b', 'LineWidth', 1.5)
    ylabel("Normalised amplitude");
    xlabel("Time (s)");

    set(gca, 'XTickLabel', 0:5:40); % Set x-axis labels

    legend("Burst", "Burst trend", "Thresholded trend", ...
        "Location", "southwest")
    % Save figure and close it
    fig = gcf;
    exportgraphics(fig, strcat(save_directory, '/', components(k), ...
        ".png"), 'Resolution',300)
    close all;