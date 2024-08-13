function durationPlotSetup(analysis_structs, phase, offset, wave)
%DURATIONPLOTSETUP Setups the plot for the duration of the slow and fast
%waves. Fast-wave is red and slow-wave is blue.
%
%   Input:
%    - analysis_structs, structure containing the analysis structures of
%    the experiments in the different phases of the estrus cycle.
%    - phase, {'proestrus', 'estrus', 'metestrus', 'diestrus', 'all'},
%    phase of the cycle to plot or plot all if 'all' is selected.
%    - offset, offset value for experiments in the same estrus phase.
%    - wave, {'sw', 'fw'}, type of wave to look at.
%
%   Return:
phases = estrusPhases();
nb_expts = size(analysis_structs.(phase), 2);
j = find(lower(phases) == phase);  % Index of the phase
color = getPhaseColor(phase);
% plotted_data = zeros(1, nb_expts); 
plotted_data = [];
x_centre = j + ((nb_expts - 1) * offset) / 2;

if strcmp(wave, "sw")
    field = "sw_duration";

elseif strcmp(wave, "fw")
    field = "fw_duration";

else
    error("Error: Incorrect wave type");
end

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    % plotted_data(k) = mean(...
    %     AS.(field)(1, (AS.(field)(1, :) > 0)));
    plotted_data = [plotted_data, AS.(field)(1, (AS.(field)(1, :) > 0))];
end

% Plot data points
swarmchart(ones(1, size(plotted_data, 2))*x_centre, ...
    plotted_data(1, :), 10, color, 'filled', 'XJitterWidth',  0.1);
hold on;

% Plot box plot
boxplot(plotted_data(1, :), 'Positions', x_centre, 'Colors', color);
ylabel("Event durations (s)")

end