function eorPlotSetup(analysis_structs, phase, offset)
%EORPLOTSETUP Setups the plot for the event presence rate.
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

for k = 1:nb_expts
    AS = analysis_structs.(phase)(k); % Analysis structure

    % Event presence rate scatter plot
    scatter(j+(k-1)*offset, AS.("EOR"), 36, color, "filled");
    hold on;

end

ylabel("Event presence rate (events/min)")
end