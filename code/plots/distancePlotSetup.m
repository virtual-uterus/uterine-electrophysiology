function distancePlotSetup(analysis_structs, phase, offset)
%DISTANCEPLOTSETUP Setups the plot for the propagation distance.
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
    analysed_event_idx = AS.("nb_samples") > 0; % Marked events indices
    plotted_data(1, k) = mean(AS.("prop_dist")(analysed_event_idx));

end

% Plot data points
swarmchart(ones(1, size(plotted_data, 2))*x_centre, ...
    plotted_data(1, :), 10, color, 'filled', 'XJitterWidth',  0.1);
hold on;

% Plot box plot
boxplot(plotted_data(1, :), 'Positions', x_centre);

ylabel("Propagation distance (mm)")
end