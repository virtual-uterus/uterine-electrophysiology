function fieldPlot(analysis_structs, field, phase, dir_path)
%FIELDPLOT Plots the field of the analysis structures based on the
%selected estrus phase.
%
%   The mean value of the field is plotted and if not a scalar the standard
%   deviation is used to plot error bars.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - field, {'duration', 'eor', 'velocity', 'frequency', 'interval'},
%       analysis structure information to plot.
%    - phase, {'proestrus', 'estrus', 'metestrus', 'diestrus', 'all'},
%    phase of the cycle to plot or plot all if 'all' is selected.
%    - dir_path, path to the directory to save figures from base_dir.
%   
%   Return: 
phases = estrusPhases();
offset = 0.15;  % Plot offset for experiments in the same phase
save_dir = join([baseDir(), dir_path], '/');

% Check the selected phase is correct
if ~any((phase == lower(phases)))
    error("Error: selected phase is not valid.")
end

% Get correct phases
if phase == "all"
    selected_phase = lower(phases(1:end-1));
else
    selected_phase = string(phase);
end

xtick_marks = zeros(1, size(selected_phase, 2));

for j = 1:size(selected_phase, 2)
    cur_phase = selected_phase(j);
    xtick_marks(j) = j + ...
        ((size(analysis_structs.(cur_phase), 2) - 1) * offset) / 2;
    switch field
        case "sw_duration"
            boxplotSetup(analysis_structs, cur_phase, offset, field);
            ylabel("Slow-wave event durations (s)")
            ylim([0, 35])
        case "fw_duration"
            boxplotSetup(analysis_structs, cur_phase, offset, field);
            ylabel("Bursting event durations (s)")
            ylim([0, 35])
        case "velocity"
            boxplotSetup(analysis_structs, cur_phase, offset, ...
                "prop_vel");
            ylabel("Propagation velocity (mm/s)")
        case "interval"
            boxplotSetup(analysis_structs, cur_phase, offset, ...
                "event_interval");
            ylabel("Event interval (s)")
        case "distance"
            boxplotSetup(analysis_structs, cur_phase, offset, ...
                "prop_dist");
            ylabel("Propagation distance (mm)")
        case "delay"
            boxplotSetup(analysis_structs, cur_phase, offset, ...
                "fw_delay");
            ylabel("Fast-wave delay (s)")
        case "occurence"
            boxplotSetup(analysis_structs, cur_phase, offset, ...
                "fw_occurence");
            ylabel("Fast-wave occurence (%)")
        case "direction"
            directionPlotSetup(analysis_structs, cur_phase, offset);
        case "frequency"
            frequencyPlotSetup(analysis_structs, cur_phase, offset);
        case "eor"
            eorPlotSetup(analysis_structs, cur_phase, offset);
        otherwise
            error("Error: selected field is not valid.")
    end

end

    xlim([0 5])
    xticks(xtick_marks);
    xticklabels(phases(1:end-1))
    
    % Get maximum ylim value and set y limits
    yl = ylim();
    ylim([0, yl(2)]);

    fig = gcf;
    exportgraphics(fig, strcat(save_dir, '/', field, ".png"), ...
        'Resolution',300)
end
