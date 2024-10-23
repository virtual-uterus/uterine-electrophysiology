function globalMetricValue(analysis_structs, metric_name)
%GLOBALMETRICVALUE Calculates and prints the global value across the estrus
% stages of the given metric based on the results in analysis structures.
%
%   Input:
%    - analysis_structs, structure with one field per estrus stage which
%    contains the analysis structures for each experiment.
%    - metric_name, name of the metric to use.
metric = [];
phase_metric = [];
phases = fieldnames(analysis_structs);

if ~isfield(analysis_structs.("estrus")(1), metric_name)
    error("Error: field does not exist")
end

for j = 1:length(phases)
    phase = string(phases{j});
    AS = analysis_structs.(phase);

    for k = size(AS)
        phase_metric = [phase_metric, AS(k).(metric_name)];
    end

    avg = mean(phase_metric, 2);
    stdev = std(phase_metric, 0, 2);

    disp([char(phase), ' ', char(metric_name), ': ', ...
        num2str(avg(1)), ' ± ', num2str(stdev(1))])
    metric = [metric, phase_metric];
    phase_metric = [];
end
    avg = mean(metric, 2);
    stdev = std(metric, 0, 2);
disp(['Global ', char(metric_name), ': ', ...
    num2str(avg(1)), ' ± ', num2str(stdev(1))])

end