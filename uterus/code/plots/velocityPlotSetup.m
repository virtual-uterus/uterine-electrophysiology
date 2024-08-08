function velocityPlotSetup(analysis_structs, phase, offset)
%VELOCITYPLOTSETUP Setups the plot for the propagation velocity.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - phase, {'proestrus', 'estrus', 'metestrus', 'diestrus', 'all'},
%    phase of the cycle to plot or plot all if 'all' is selected.
%    - offset, offset value for experiments in the same estrus phase.
%
%   Return:
phases = estrusPhases();
nb_expts = size(analysis_structs.(phase), 2);
j = find(lower(phases) == phase);  % Index of the phase
color = getPhaseColor(phase);
plotted_data = zeros(2, nb_expts);
data_pts = [];

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    analysed_event_idx = AS.("nb_samples") > 0; % Marked events indices
    %     data_pts = horzcat(data_pts, AS.("prop_vel")(analysed_event_idx));
    plotted_data(1, k) = mean(AS.("prop_vel")(analysed_event_idx));
    plotted_data(2, k) = std(AS.("prop_vel")(analysed_event_idx));

    %   % Velocity box plot
    %     boxplot(AS.("prop_vel")(analysed_event_idx), ...
    %         'Positions', j+(k-1)*offset, ...
    %         'Widths', 0.05);
    errorbar(j+(k-1)*offset, plotted_data(1, k), plotted_data(2, k), ...
        '.', 'Color', color)
    hold on;
end

% swarmchart(j, data_pts, 20, color, 'filled');
% hold on;
% boxplot(data_pts,  'Positions', j, 'Widths', 0.05);
x_centre = j + ((nb_expts - 1) * offset) / 2;
boxplot(plotted_data(1, :), 'Positions', x_centre, 'Widths', 0.05);

ylabel("Propagation velocity (mm/s)")
end