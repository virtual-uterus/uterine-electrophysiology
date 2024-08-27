%% Set paths and load parameters
dir_path = "electrophys/data";
estrus_config = "estrus_config.toml";

load_directory = join([baseDir(), dir_path], '/');
config_file_path = join([load_directory, estrus_config], '/');

% Get params from toml file
toml_map = toml.read(config_file_path);
params = toml.map_to_struct(toml_map);

phase_data = params.phases;
phases = fieldnames(phase_data);
analysis_structs = struct();  % Structure containing phase results

for j = 1:size(phases, 1)
    disp(strcat("Current phase: ", phases{j}));
    base_names = phase_data.(phases{j});

    analysis_structs.(phases{j}) = arrayfun(@createAnalysisStruct, ...
        size(base_names, 2)); % Create array of empty analysis structures

    for k = 1:size(base_names, 2)
        disp(strcat("  Expt ", base_names(k)));
        analysis_structs.(phases{j})(k) = markedDataAnalysis( ...
            dir_path, string(base_names(k)));
    end
end