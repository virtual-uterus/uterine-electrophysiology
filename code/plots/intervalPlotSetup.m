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
plotted_data = zeros(1, nb_expts); 
x_centre = j + ((nb_expts - 1) * offset) / 2;

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    plotted_data(k) = mean(...
        AS.("event_interval")(1, (AS.("event_interval")(1, :) > 0)));
end

% Plot data points
swarmchart(ones(1, size(plotted_data, 2))*x_centre, ...
    plotted_data(1, :), 10, color, 'filled', 'XJitterWidth',  0.1);
hold on;

% Plot box plot
boxplot(plotted_data(1, :), 'Positions', x_centre);
ylabel("Event interval (s)")
end