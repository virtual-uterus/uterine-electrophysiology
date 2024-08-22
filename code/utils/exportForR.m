function exportForR(analysis_structs, dir_path)
%CONVERTTOR Exports certain metrics into csv tables that can be read into 
% R. The function creates one folder for each estrus stage at the end of
% dir_path. 
%
%   The exported metrics are: sw_duration, fw_duration, fw_occurence,
%   prop_vel, event_interval, and fw_delay.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - dir_path, path to the directory to save data from base_dir.

%   Return:
stages = fieldnames(analysis_structs);
save_dir = join([baseDir(), dir_path], '/');
export_metrics = ["sw_duration", "fw_duration", "fw_occurence", ...
    "event_interval", "prop_vel", "fw_delay"];  % Metrics to export

for j = 1:numel(stages)
    stage_name = stages{j};
    stage_data = analysis_structs.(stage_name);
    stage_dir = fullfile(save_dir, stage_name);

    % Create a folder for the current estrous stage if it doesn't exist
    if ~exist(stage_dir, 'dir')
        mkdir(stage_dir);
    end

    for metric = export_metrics
        % Check if metric exists in structure
        if isfield(stage_data, metric)
            % Allocate array for metric data for all experiments
            data = nan(length(stage_data), max(arrayfun(@(x) length( ...
                x.(metric)), stage_data)));
        else
            warning("Field %s not found in stage %s. Skipping", ...
                metric, stage_name);
            continue
        end

        for k = 1:length(stage_data)
            metric_data = stage_data(k).(metric);
            data(k, 1:length(metric_data)) = metric_data(1, :);
        end
        filename = fullfile(stage_dir, metric + '.csv');
        writematrix(data, filename);
    end
end
end