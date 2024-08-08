function frequencyPlotSetup(analysis_structs, phase, offset)
%FREQUENCYPLOTSETUP Setups the plot for the frequency of the slow and fast
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
tiny_bit = 0.03;

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure

%     % Slow-wave duration    
    boxplot(AS.("fw_frequency")(1, :), 'Positions', j+(k-1)*offset, ...
        'Colors', 'b', 'Widths', 0.05, 'BoxStyle', 'filled', ...
        'Symbol', '+b'); 
    hold on;

%     % Fast-wave duration
%     boxplot(AS.("fw_fhigh")(1, :), 'Positions', j+tiny_bit+k*offset, ...
%         'Colors', 'r', 'Widths', 0.05, 'BoxStyle', 'filled', ...
%         'Symbol', '+r'); hold on;
%     boxplot(AS.("fw_flow")(1, :), 'Positions', j+tiny_bit+k*offset, ...
%         'Colors', 'b', 'Widths', 0.05, 'BoxStyle', 'filled', ...
%         'Symbol', '+b');
%     boxplot(AS.("fw_bandwidth")(1, :), 'Positions', j+tiny_bit+k*offset, ...
%         'Widths', 0.05, 'Symbol', '+k'); 
end

ylabel("Event frequencies (Hz)")
title("Slow-wave: blue, Fast-wave: red")
end