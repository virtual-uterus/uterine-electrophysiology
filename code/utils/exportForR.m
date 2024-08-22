function exportForR(analysis_structs, dir_path)
%CONVERTTOR Transform data into csv tables that can be read into R.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - dir_path, path to the directory to save data from base_dir.

%   Return:
stages = fieldnames(analysis_structs);
save_dir = join([baseDir(), dir_path], '/');

for i = 1:numel(stages)
    stage_name = stages{i};
    stage_data = analysis_structs.(stage_name);
    
    % Extract data
    data_table = struct2table(stage_data);

    % Write each stage's data to a separate CSV file
    writetable(data_table, fullfile(save_dir, [stage_name '.csv']));
end
end