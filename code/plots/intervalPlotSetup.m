function intervalPlotSetup(analysis_structs, phase, offset)
%INTERVALPLOTSETUP Setups the plot for the event interval.
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
%     data_pts = horzcat(data_pts, ...
%         AS.("event_interval")(1, (AS.("event_interval")(1, :) > 0)));
    plotted_data(1, k) = mean(...
        AS.("event_interval")(1, (AS.("event_interval")(1, :) > 0)));
    plotted_data(2, k) = avgDeviation(...
        AS.("event_interval")(2, (AS.("event_interval")(2, :) > 0)), ...
        AS.("event_interval")(3, (AS.("event_interval")(3, :) > 0)));


    % Interval plot    
    errorbar(j+(k-1)*offset, plotted_data(1, k), plotted_data(2, k), ...
        '.', 'Color', color)
    hold on;
    hold on;

end

% swarmchart(j, data_pts, 20, color, 'filled');
% hold on;
% boxplot(data_pts,  'Positions', j, 'Widths', 0.05);
x_centre = j + ((nb_expts - 1) * offset) / 2;
boxplot(plotted_data(1, :), 'Positions', x_centre, 'Widths', 0.05);
ylabel("Event interval (s)")
end