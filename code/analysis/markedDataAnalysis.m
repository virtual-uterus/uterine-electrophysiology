function [AS, export_cells] = markedDataAnalysis(dir_path, base_name, ...
    export_stage)
%MARKEDDATAANALYSIS Performs the frequency analysis on the input data on
%marked data exported from UGEMS.
%
%   base_dir is $HOME/Documents/phd/ and set in utils/baseDir()
%
%   Input:
%    - dir_path, path to the directory containing the dataset from base_dir
%    - base_name, name of the dataset.
%    - export_stage, {proestrus, estrus, metestrus, diestrus, none},
%       stage of the estrus to export to. If empty data is not exported.
%       Default value is none.
%
%   Return:
%    - AS, analysis structure containing the analysis metrics, see
%    createAnalysisStruct.m for more details.
%    - export_cells, cell array containing all the processed data. Each row
%       contains the data for one event. The columns are in order: 
%       prop_vel, prop_direction, event_interval, sw_duration, fw_duration, 
%       fw_delay, fw_presence
if nargin < 3
    export_stage = "none";
end

% Check export stage
if ~any(strcmp(export_stage, [ ...
        "proestrus", "estrus", "metestrus", "diestrus", "none"]))
    error("Error: export stage is not valid")
end

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
[data, tvec, Fs, electrode_cnfg, marks, electrode_dist] = loadExptData(...
    mat_file_path, params.start_time, params.end_time);

close all; % Close the UTEMS window

win_size = double(params.win_size .* Fs);
nb_points = length(tvec); % Number of sampling points
nb_marks = length(marks);

if nb_marks == 0
    % Safety check for marks
    error("The data does not contain any marks and cannot be processed");
end

[~, event_idx] = find(cellfun('length', marks) > params.min_nb_chns);

% Remove unlabeled marks if the have been extracted in the index list
if event_idx(end) == nb_marks
    event_idx = event_idx(1:end-1);
end

nb_events = length(event_idx);
valid_events = 0; % Count the number of events in desired times

% Create analysis structure
AS = createAnalysisStruct(nb_events);
AS.name = base_name;
AS.transition = params.transition;

export_metrics = ["prop_vel", "prop_direction", "event_interval", ...
    "sw_duration", "fw_duration", "fw_delay", "fw_presence"];
export_cells = cell(nb_events, length(export_metrics));

%% Frequency analysis on events
for j = 1:nb_events
    k = event_idx(j);

    event_data = removeDuplicatePoints( ...
        marks{k}(:, 3:4)); % Timestamps and chns of the event

    if max(event_data(:, 1)) < params.start_time || ...
            max(event_data(:, 1)) > params.end_time
        % Skip events that are not within selected times
        continue
    else
        event_data(:, 1) = event_data(:, 1) - double(params.start_time);
        valid_events = valid_events + 1;
    end

    disp(['    Processing event number ', num2str(k)])

    if length(event_data) > params.min_nb_chns

        % If using channels 65 to 128 remove 64
        if all(event_data(:, 2) > 64)
            event_data(:, 2) = event_data(:, 2) - 64;
        end

        % Estimate propagation properties
        [prop_dist, prop_vel, prop_direction] = propagationAnalysis( ...
            arrangeTimes(event_data, electrode_cnfg), ...
            electrode_dist);

        % Export propagation properties
        export_cells{k, 1} = prop_vel(:)';
        export_cells{k, 2} = prop_direction;

        AS.prop_vel(1, j) = mean(prop_vel, 'all', 'omitnan');
        AS.prop_dist(1, j) = prop_dist;
        AS.prop_direction(1, j) = prop_direction;

        if valid_events > 1
            past_event_data = removeDuplicatePoints( ...
                marks{event_idx(j-1)}(:, 3:4)); % Timestamps and chns
            % Reset times
            past_event_data(:, 1) = past_event_data(:, 1) - ...
                double(params.start_time);

            % If using channels 65 to 128 remove 64
            if all(past_event_data(:, 2) > 64)
                past_event_data(:, 2) = past_event_data(:, 2) - 64;
            end
            [event_interval, AS.event_interval(3, j-1)] = ...
                eventIntervalAnalysis(past_event_data, event_data);

            export_cells{k, 3} = event_interval;

            AS.event_interval(1, j-1) = mean(event_interval);
            AS.event_interval(2, j-1) = std(event_interval);
        end

        start_times = round(event_data(:, 1) .* Fs - ...
            win_size * params.win_split);
        end_times = round(event_data(:, 1) .* Fs + ...
            win_size * (1 - params.win_split));

        % Ensure start and end times are valid
        start_times(start_times <= 0) = 1; % Reset to 1 if negative or 0
        end_times(end_times > nb_points) = nb_points; % Reset to be end time

        events = data(start_times:end_times, event_data(:, 2));
        [fwave, swave] = separateWaves(events, ...
            params.highpass_cutoff_freq, ...
            params.lowpass_cutoff_freq, ...
            Fs);

        % Perform analysis on slow-wave
%         [AS.sw_frequency(1, j), AS.sw_frequency(2, j)] = ...
%             frequencyAnalysis(swave, Fs);

        [sw_duration, fw_duration, fw_delay] = temporalAnalysis(...
            swave, fwave, Fs, params.win_split);

        % Populate AS with temporal metric
        export_cells{k, 4} = sw_duration;
        AS.sw_duration(1, j) = mean(sw_duration, 'omitnan');
        AS.sw_duration(2, j) = std(sw_duration, 'omitnan');

        export_cells{k, 5} = fw_duration;
        AS.fw_duration(1, j) = mean(fw_duration, 'omitnan');
        AS.fw_duration(2, j) = std(fw_duration, 'omitnan');

        export_cells{k, 6} = fw_delay;
        AS.fw_delay(1, j) = mean(fw_delay, 'omitnan');
        AS.fw_delay(2, j) = std(fw_delay, 'omitnan');

        fw_presence = 100 * ( ...
            sum(~isnan(fw_duration)) ./ numel(fw_duration));
        export_cells{k, 7} = fw_presence;
        AS.fw_presence(j) = fw_presence;
        
        % Perform analysis on fast-wave
%         [AS.fw_frequency(1, j), AS.fw_frequency(2, j)] = ...
%             frequencyAnalysis(fwave, Fs);
%         [AS.fw_bandwidth(1, j), AS.fw_bandwidth(2, j), ...
%             AS.fw_flow(1, j), AS.fw_flow(2, j), ...
%             AS.fw_fhigh(1, j), AS.fw_fhigh(2, j)] = ...
%             frequencyAnalysis(fwave, Fs, 'power');

        AS.nb_samples(j) = length(event_data); % Add the number of chns

    else
        % Skip if not enough points
        disp(['    Only ', num2str(length(event_data)), ...
            ' events: skipping analysis'])
    end
end

%% Reset indexation to remove unprocessed events if needed
if AS.nb_events ~= valid_events
    AS = removeUnprocessedEvents(AS);
    AS.nb_events = valid_events;
end

% Remove unprocessed events from export cells
export_cells = export_cells(cellfun(@any, export_cells(:, 1)), :); 

% Event occurrence rate in events/min
AS.EOR = 60 ./ mean(AS.event_interval(1, :)); 
end