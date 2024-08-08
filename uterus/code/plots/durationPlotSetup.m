function durationPlotSetup(analysis_structs, phase, offset)
%DURATIONPLOTSETUP Setups the plot for the duration of the slow and fast
%waves. Fast-wave is red and slow-wave is blue.
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
tiny_bit = 0.08;

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure
    analysed_event_idx = AS.("nb_samples") > 0; % Marked events indices

    % Slow-wave duration    
    boxplot(AS.("sw_duration")(1, analysed_event_idx), ...
        'Positions', j+(k-1)*offset, ...
        'Colors', 'b', 'Widths', 0.05, 'BoxStyle', 'filled', ...
        'Symbol', '+b', 'MedianStyle', 'target'); 
    hold on;

    % Fast-wave duration
    boxplot(AS.("fw_duration")(1, analysed_event_idx), ...
        'Positions', j+tiny_bit+(k-1)*offset, ...
        'Colors', 'r', 'Widths', 0.05, 'BoxStyle', 'filled', ...
        'Symbol', '+r', 'MedianStyle', 'target'); 

end

ylabel("Event durations (s)")
title("Slow-wave: blue, Fast-wave: red")
end