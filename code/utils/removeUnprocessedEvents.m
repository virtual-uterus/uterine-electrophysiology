function clean_AS = removeUnprocessedEvents(AS)
%REMOVEUNPROCESSEDEVENTS Removes events that have not been processed and
%correspond to those where the number of samples is 0.
%
%   Input:
%    - AS, analysis structure containing the analysis metrics, see
%    createAnalysisStruct.m for more details. 
%
%   Return:
%    - clean_AS, analysis structure with only processed events.
fields = fieldnames(AS);
valid_indices = AS.nb_samples > 0;  % Use number of samples to get events

for j = 4:length(fields) % Skip first few fields
    AS.(string(fields(j))) = AS.(string(fields(j)))(:, valid_indices);
end

% Remove the last interval which will always be 0
AS.("event_interval") = AS.("event_interval")(:, 1:end-1);

clean_AS = AS;
end