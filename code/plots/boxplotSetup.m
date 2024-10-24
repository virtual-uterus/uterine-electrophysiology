function boxplotSetup(analysis_structs, phase, offset, field)
%BOXPLOTSETUP Setups the plot for the fields that use boxplots.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - phase, {'proestrus', 'estrus', 'metestrus', 'diestrus', 'all'},
%    phase of the cycle to plot or plot all if 'all' is selected.
%    - offset, offset value for experiments in the same estrus phase.
%    - field, field to plot.
%
%   Return:
phases = estrusPhases();
nb_expts = size(analysis_structs.(phase), 2);
j = find(lower(phases) == phase);  % Index of the phase
color = getPhaseColor(phase);
mean_data = zeros(1, nb_expts); 
plotted_data = [];
x_centre = j + ((nb_expts - 1) * offset) / 2;

if ~isfield(analysis_structs.(phase), field)
    error("Error: Incorrect field");
end

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    mean_data(k) = mean(AS.(field)(1, :));
    plotted_data = [plotted_data, AS.(field)(1, :)];
end

% Plot data points
swarmchart(ones(1, size(plotted_data, 2))*x_centre, ...
    plotted_data(1, :), 10, color, 'filled', 'XJitterWidth',  0.1);
hold on;

% Plot mean points
plot(ones(1, nb_expts) .* x_centre, mean_data, '.k', ...
    'MarkerSize', 13);

% Plot box plot
boxplot(plotted_data(1, :), 'Positions', x_centre, 'Colors', color);

end