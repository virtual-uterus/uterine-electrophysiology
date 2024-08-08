function analysis_struct = createAnalysisStruct(nb_events)
%CREATEANALYSISSTRUCT Creates a structure that contains all the analysis
%metrics.
%
%   Input:
%    - nb_events, number of events in data to initialise the arrays.
%
%   Return:
%    - analysis_struct, analysis structure containing the empty arrays for
%    the analysis metrics.
%       nb_events, number of events to analyse in the data.
%       EOR, event occurrence rate.
%       prop_vel, propagation velocity in mm/s, prop_vel(1 x NB_EVENTS).
%       prop_dist, propagation distance in mm, 
%           prop_distance(1 x NB_EVENTS).
%       prop_direction, propagation direction, 
%           prop_direction(1 x NB_EVENTS).
%       event_interval, time between two events, 
%           event_interval(3 x NB_EVENTS-1),
%           row 1: mean, row 2: std, row 3: number of samples.
%       nb_samples, number of channels analysed in each event,
%           nb_samples(1 x NB_EVENTS).
%       sw_duration, slow-wave duration, sw_duration(2 x NB_EVENTS),
%           row 1: mean, row 2: std.
%       fw_duration, fast-wave duration, fw_duration(2 x NB_EVENTS),
%           row 1: mean, row 2: std.
%       fw_delay, delay between the start of the slow-wave and the start of
%       the fast-wave in seconds, fw_delay(2 x NB_EVENTS),
%           row 1: mean, row 2: std.
%       fw_percentage, percentage of events with a fast-wave, 
%           fw_percentage(1 x NB_EVENTS),
%
%   Unused metrics that are commented out:
%       sw_frequency, slow-wave max frequency, sw_frequency(2 x NB_EVENTS),
%           row 1: mean, row 2: std.
%       fw_frequency, fast-wave max frequency, fw_frequency(2 x NB_EVENTS),
%           row 1: mean, row 2: std.
%       fw_bandwidth, frequency bandwidth with 95% of signal power, 
%           fw_bandwidth(2 x NB_EVENTS), row 1: mean, row 2: std.
%       fw_fhigh, high limit of 95% of signal power frequency band,
%           fw_fhigh(2 x NB_EVENTS), row 1: mean, row 2: std.
%       fw_flow, low limit of 95% of signal power frequency band,
%           fw_flow(2 x NB_EVENTS), row 1: mean, row 2: std.
analysis_struct = struct; % Create empty structure
metric_arr = zeros(2, nb_events); % Create array for metric and std

%% Populate the structure
% General information
analysis_struct.name = string; % Experiment name
analysis_struct.nb_events = nb_events;
analysis_struct.EOR = 0;
analysis_struct.nb_samples = zeros(1, nb_events);
analysis_struct.event_interval = zeros(3, nb_events-1);

% Propagation information
analysis_struct.prop_vel = zeros(1, nb_events);
analysis_struct.prop_dist = zeros(1, nb_events);
analysis_struct.prop_direction = zeros(1, nb_events);

% Slow-wave information
% analysis_struct.sw_frequency = metric_arr;
analysis_struct.sw_duration = metric_arr;

% Fast-wave information
% analysis_struct.fw_frequency = metric_arr;
% analysis_struct.fw_bandwidth = metric_arr;
% analysis_struct.fw_fhigh = metric_arr;
% analysis_struct.fw_flow = metric_arr;
analysis_struct.fw_duration = metric_arr;
analysis_struct.fw_delay = metric_arr;
analysis_struct.fw_percentage = zeros(1, nb_events);
end
