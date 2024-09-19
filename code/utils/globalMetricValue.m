function globalMetricValue(analysis_structs, metric_name)
%GLOBALMETRICVALUE Calculates and prints the global value across the estrus
% stages of the given metric based on the results in analysis structures.
%
%   Input:
%    - analysis_structs, structure with one field per estrus stage which
%    contains the analysis structures for each experiment.
%    - metric_name, name of the metric to use.
metric = [];
phases = fieldnames(analysis_structs);

if ~isfield(analysis_structs.("estrus")(1), metric_name)
    error("Error: field does not exist")
end

for j = 1:length(phases)
    phase = string(phases{j});
    AS = analysis_structs.(phase);

    for k = size(AS)
        metric = [metric, AS(k).(metric_name)];
    end
end
disp(['Global ', char(metric_name), ': ', ...
    num2str(mean(metric)), ' ± ', num2str(std(metric))])

end