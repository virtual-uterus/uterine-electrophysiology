function cleaned_data = removeDuplicatePoints(event_data)
%REMOVEDUPLICATEPOINTS Finds the duplicate timestamps and removes the one
%that is furthest from the average timestamp value. If there are no
%duplicates the function exits early and does not change the data.
%
%   Input:
%    - event_data, data array that contains the timestamps in the first
%    column and the channel number associated in the second,
%    event_data(N, 2).
%
%   Return:
%    - cleaned_data, data array that contains the timestamps in the first
%    column and the channel number associated in the second without
%    duplicates, event_data(N, 2).
cleaned_data = event_data;

% Find duplicate channel indices
[~, unique_idx] = unique(event_data(:, 2), 'stable');
dup_chns_idx = setdiff(1:length(event_data), unique_idx);

if isempty(dup_chns_idx)
    % If there are no duplicate channels exit early
    return 
end

mean_time = mean(event_data(:, 1)); % Used to compare times
dup_chns = event_data(dup_chns_idx, 2); % Duplicated channel numbers
idx_to_remove = zeros(size(dup_chns)); 

for j = 1:length(dup_chns)
    % Loop through all duplicates and find the aberrant ones
    dup_idx = find(event_data(:, 2) == dup_chns(j)); % Find the dup idx
    mean_diff = abs(mean_time - event_data(dup_idx, 1));
    [~, max_idx] = max(mean_diff); % Get the furthest from the mean
    idx_to_remove(j) = dup_idx(max_idx);
end

cleaned_data(idx_to_remove, :) = [];
end