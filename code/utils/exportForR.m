function exportForR(analysis_structs, export_structs, dir_path)
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
%    - export_structs, structure containing the raw data  of
%    the experiments in the different phases of the estrus cycle.
%    - dir_path, path to the directory to save data from base_dir.

%   Return:
stages = fieldnames(analysis_structs);
save_dir = join([baseDir(), dir_path], '/');
export_metrics = ["prop_vel", "prop_direction", "event_interval", ...
    "sw_duration", "fw_duration", "fw_delay", "fw_occurrence"];

for j = 1:numel(stages)
    stage_name = stages{j};
    stage_data = analysis_structs.(stage_name);
    stage_dir = fullfile(save_dir, stage_name);

    % Create a folder for the current estrous stage if it doesn't exist
    if ~exist(stage_dir, 'dir')
        mkdir(stage_dir);
    end

    % Create experiment and transition labels
    expts = string(export_structs.(stage_name)(:, 1)); % Expts labels
    expts_names = [stage_data.("name")];
    transition_expts = expts_names(logical([stage_data.("transition")]));
    transitions = sum(expts == transition_expts, 2); % Transition labels

    for metric = export_metrics
        % Array with metric data for all experiments
        data = [stage_data.(metric)];

        filename = fullfile(stage_dir, metric + '.csv');
        writematrix(expts', filename);
        writematrix(transitions', filename, "WriteMode", "append");
        writematrix(data(1, :), filename, "WriteMode", "append");
    end
end
end
