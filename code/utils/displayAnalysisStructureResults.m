function displayAnalysisStructureResults(AS)
%DISPLAYANALYSISSTRUCTURERESULTS Prints out the results of an analysis 
%structure. See createAnalysisStructure.m for more details on the contents
%of an AS.
%
%   Input:
%    - AS, analysis structure containing the analysis metrics, see
%    createAnalysisStruct.m for more details. 
% Display results
disp(strcat("Experiment ID code: ", AS.name))
disp([' Number of events: ', num2str(AS.nb_events)])
disp([' Event occurrence rate: ', num2str(AS.EOR),  ' events/min']);
disp([' Average event interval: ', num2str( ...
    mean(AS.event_interval(1, :))), ...
    ' ± ', ...
    num2str(avgDeviation( ...
        AS.event_interval(2, :), ...
        AS.event_interval(3, :) ...
        )), ...
    ' s'
    ]);

% Propagation properties
disp(' Propagation properties');
disp(['  Average propagation velocity: ', num2str(mean(...
    AS.prop_vel)), ...
    ' ± ', num2str(std(AS.prop_vel)), ' mm/s']);
disp(['  Average propagation distance: ', num2str(mean( ...
    AS.prop_dist)), ...
    ' ± ', num2str(std(AS.prop_dist)), ' mm']);
disp('  Propagation direction:');
disp(['   Ovaries -> cervix: ', num2str( ...
    100*sum(AS.prop_direction == 1) / AS.nb_events), ' %']);
disp(['   Cervix -> ovaries: ', num2str( ...
    100*sum(AS.prop_direction < 0) / AS.nb_events), ' %']);
disp(['   Disorganised: ', num2str( ...
    100*sum(AS.prop_direction == 0) / AS.nb_events), ' %']);
% Slow-wave properties
disp(' Slow-wave properties');
disp(['  Average event duration: ', ...
    num2str(mean(AS.sw_duration(1, :))), ' ± ', num2str( ...
    avgDeviation(AS.sw_duration(2, :), AS.nb_samples)), ' s'])
% disp(['  Average max frequency: ', ...
%     num2str(mean(AS.sw_frequency(1, :))), ' ± ', num2str( ...
%     avgDeviation(AS.sw_frequency(2, :), AS.nb_samples)), ' Hz'])

% Fast-wave properties
disp(' Fast-wave properties');
disp(['  Average event duration: ', ...
    num2str(mean(AS.fw_duration(1, :))), ' ± ', num2str( ...
    avgDeviation(AS.fw_duration(2, :), AS.nb_samples)), ' s'])
disp(['  Average delay: ', ...
    num2str(mean(AS.fw_delay(1, :))), ' ± ', num2str( ...
    avgDeviation(AS.fw_delay(2, :), AS.nb_samples)), ' s'])
disp(['  Average bursting occurrence: ', num2str(mean( ...
    AS.fw_occurrence)), ...
    ' ± ', num2str(std(AS.fw_occurrence)), ' %']);
% disp(['  Average max frequency: ', ...
%     num2str(mean(AS.fw_frequency(1, :))), ' ± ', num2str( ...
%     avgDeviation(AS.fw_frequency(2, :), AS.nb_samples)), ' Hz'])
% disp(['  Average 95% power frequency band: ', ...
%     num2str(mean(AS.fw_bandwidth(1, :))), ' ± ', num2str( ...
%     avgDeviation(AS.fw_bandwidth(2, :), AS.nb_samples)), ' Hz'])
% disp(['  Average low frequency band limit: ', ...
%     num2str(mean(AS.fw_flow(1, :))), ' ± ', num2str( ...
%     avgDeviation(AS.fw_flow(2, :), AS.nb_samples)), ' Hz'])
% disp(['  Average high frequency band limit: ', ...
%     num2str(mean(AS.fw_fhigh(1, :))), ' ± ', num2str( ...
%     avgDeviation(AS.fw_fhigh(2, :), AS.nb_samples)), ' Hz'])
end
