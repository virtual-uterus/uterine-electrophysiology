% Script to produce signal plots for figures
% Last modified: Aug 2024
% Author Mathias Roesler
%% Load data and parameters
dir_path = "electrophys/data";
save_path = "electrophys/figures/signals";
base_name = "AWB013";

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
norm_data = data ./ max(abs(data));
norm_fwave = fwave ./ max(abs(fwave));
norm_swave = swave ./ max(abs(swave));

components = ["raw_signal", "high_frequency", "low_frequency"];
all_data = cat(3, norm_data, norm_fwave, norm_swave);

%% Plot all data
for k = 1:3
    figure; % Create a new figure    
    %     set(gcf, 'Position', [100, 100, 800, 1200]); % Rectangular figure

    y_axis = all_data(:, electrode_cnfg(:, 2), k);
    y_axis = fliplr(y_axis); % Flip to plot from bottom to top of config

    start_val = 100*Fs;
    end_val = 400*Fs;

    for j = 5:10
        plot(tvec(start_val:end_val), ...
            y_axis(start_val:end_val, j) + (j-1)*4.0, ...
            'k', 'LineWidth', 1.5);
        hold on;
    end

    set(gca, 'YTick', 16:4:36); % Reset y-axis ticks
    set(gca, 'YTickLabel', 1:6); % Set y-axis labels
    set(gca, 'XTickLabel', 0:50:300); % Set x-axis labels
    ylim([12 39]);

    ylabel("Electrical signals");
    xlabel("Time (s)");

    % Save figure and close it
    fig = gcf;
    exportgraphics(fig, strcat(save_directory, '/', components(k), ...
        ".png"), 'Resolution',300)
    close all;
end