function exportForR(export_struct, dir_path)
%EXPORTFORR Exports certain metrics into csv tables that can be read into 
% R. The function creates one folder for each estrus stage at the end of
% dir_path. 
%
%   The exported metrics are: sw_duration, fw_duration, fw_occurrence,
%   prop_vel, event_interval, and fw_delay.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - dir_path, path to the directory to save data from base_dir.

%   Return:
stages = fieldnames(export_struct);
save_dir = join([baseDir(), dir_path], '/');
export_metrics = ["prop_vel", "prop_direction", "event_interval", ...
    "sw_duration", "fw_duration", "fw_delay", "fw_occurrence"];

for j = 1:numel(stages)
    stage_name = stages{j};
    stage_data = export_struct.(stage_name);
    stage_dir = fullfile(save_dir, stage_name);

    % Create a folder for the current estrous stage if it doesn't exist
    if ~exist(stage_dir, 'dir')
        mkdir(stage_dir);
    end

    cnt = 2; % Metric counter
    
    for metric = export_metrics
        % Allocate array for metric data for all experiments
        data = nan(64, size(stage_data, 1));

        for k = 1:length(stage_data)
            metric_data = stage_data{k, cnt};
            data(1:length(metric_data), k) = metric_data(:);
        end

        accum = accumarray(grp2idx(string(stage_data(:, 1)')), 1);
        sum_accum = cumsum(accum);
        event_numbers = zeros(1, size(stage_data(:, 1), 1));

        for l = 1:size(accum, 1)
            event_numbers(sum_accum(l) - accum(l) + 1:sum_accum(l)) = ...
                1:accum(l);
        end

        filename = fullfile(stage_dir, metric + '.csv');
        writematrix(string(stage_data(:, 1))', filename);
        writematrix(event_numbers, filename,"WriteMode", "append");
        writematrix(data, filename, "WriteMode", "append");

        cnt = cnt + 1; % Update counter
    end
end
end
