function plotMultiChannel(data, x_axis, electrode_cnfg, val, row)
%PLOTMULTICHANNEL Plots rows or columns of the data given the electrode
%configuration. The data should be normalised.
%
%   Input:
%    - data, data to plot, data(SAMPLES x NB_CHANNELS)
%    - x_axis, values of the x axis, x_axis(SAMPLES x 1)
%    - electrode_cnfg, matrix of the electrode configuration.
%    - val, value of the row or column to plot.
%    - row, true for plotting a row, false for plotting a column,
%    default value is false.
%
if nargin < 5
    row = false;
end

% Error checks
if val < 1
    error("Error: val cannot be less than 1")
end

if row
    if val > size(electrode_cnfg, 1)
        error("Error: val cannot be greater than the number of rows")
    end

    y_axis = data(:, electrode_cnfg(val, :));

else
    if val > size(electrode_cnfg, 2)
        error("Error: val cannot be greater than the number of columns")
    end

    y_axis = data(:, electrode_cnfg(:, val));
end

y_axis = fliplr(y_axis); % Flip to plot from bottom to top of config 

nb_subplots = size(y_axis, 2);

for j = 1:nb_subplots
    plot(x_axis, y_axis(:, j) + (j-1)*2.5); hold on;
end
