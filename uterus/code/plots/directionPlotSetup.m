function directionPlotSetup(analysis_structs, phase, offset)
%DIRECTIONPLOTSETUP Setups the plot for the propagation directions.
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
cmap = [[0.4940 0.1840 0.5560];
    [0.3010 0.7450 0.9330];
    [0.8500 0.3250 0.0980]];

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    prop_direction = AS.("prop_direction")(1, :);
    nb_events = numel(prop_direction);

    direction_percents = 100 .* [(sum(prop_direction > 0) / nb_events)
     (sum(prop_direction < 0) / nb_events)
     (sum(prop_direction == 0) / nb_events)]; % O -> C, C -> O, D
    b = bar(j+(k-1)*offset, direction_percents, ...
        "stacked", ...
        "BarWidth", 0.05, ...
        "FaceColor", "flat");
    hold on;
    for l = 1:size(direction_percents, 1)
        b(l).CData = cmap(l, :);
    end

end

ylabel("Propagation directions (%)")

legend("Ovaries -> cervix", "Cervix -> ovaries", "Disorganised")
end