function plotAllChannels(data, x_axis, electrode_cnfg, row)
%PLOTMULTICHANNEL Plots rows or columns of the data given the electrode
%configuration. The data should be normalised.
%
%   Input:
%    - data, data to plot, data(SAMPLES x NB_CHANNELS)
%    - x_axis, values of the x axis, x_axis(SAMPLES x 1)
%    - electrode_cnfg, matrix of the electrode configuration.
%    - row, true for plotting a row, false for plotting a column,
%    default value is false.
%
if nargin < 4
    row = false;
end

if row
    nb_subplots = size(electrode_cnfg, 1);
    tiledlayout(nb_subplots, 1);
else
    nb_subplots = size(electrode_cnfg, 2);
    tiledlayout(1, nb_subplots);
end

for j = 1:nb_subplots
    nexttile
    plotMultiChannel(data, x_axis, electrode_cnfg, j, row);
end