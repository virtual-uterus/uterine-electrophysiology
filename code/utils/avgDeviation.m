function avg_std = avgDeviation(std_arr, nb_event_arr)
%AVGDEVIATION Calculates the average standard deviation of a list of
%standard deviations.
%
%   The method for calculating the standard deviation depends on the number
%   of samples used for each group. 
%
%   Input:
%    - std_arr, array containing the standard deviations.
%    - nb_event_arr, array containing the number of samples used for each
%    standard deviation calculation.
%   
%   Return: 
%    - avg_std, average standard deviation value
if range(nb_event_arr) == 0
    avg_std = sqrt(sum(std_arr .^ 2) / length(nb_event_arr));

else
    num = sum((nb_event_arr - 1) .* (std_arr .^ 2));
    denom = sum(nb_event_arr) - length(nb_event_arr);
    avg_std = sqrt(num / denom);
end
end