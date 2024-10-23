function globalMetricValue(analysis_structs, metric_name)
%GLOBALMETRICVALUE Calculates and prints the global value across the estrus
% stages of the given metric based on the results in analysis structures.
%
%   Input:
%    - analysis_structs, structure with one field per estrus stage which
%    contains the analysis structures for each experiment.
%    - metric_name, name of the metric to use.
metric = [];
mean_metric = [];
phases = fieldnames(analysis_structs);

if ~isfield(analysis_structs.("estrus")(1), metric_name)
    error("Error: field does not exist")
end

for j = 1:length(phases)
    phase = string(phases{j});
    AS = analysis_structs.(phase);

    for k = 1:size(AS, 2)
        metric_data = AS(k).(metric_name);
        metric = [metric, metric_data(1, :)];
        mean_metric = [mean_metric, mean(metric_data(1, :))];
    end

    disp([char(phase), ' ', char(metric_name), ': ', ...
        num2str(mean(mean_metric)), ' ± ', num2str(std(mean_metric))])
    mean_metric = [];
end

disp(['Global ', char(metric_name), ': ', ...
    num2str(mean(metric)), ' ± ', num2str(std(metric))])

end