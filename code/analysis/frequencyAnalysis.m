function varargout = frequencyAnalysis(data, Fs, varargin)
%FREQUENCYANALYSIS Performs the frequency analysis on the input data and
%returns the results.
%
% The function computes either the FFT or the 95% power band based on the
% inputed arguments. The default is the FFT. 
%
%   Input:
%    - data, data to process, data(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency in Hz.
%    - vargin, optional arguments:
%       mode, method to use {'FFT', 'power'}, default value FFT.
%       nb_FFT_samples, number of samples for the FFT, default value
%           length(data).
%   
%   Return (for FFT mode):
%    - mean_f, mean frequency from the analysis of the signal.
%    - std_f, standard deviation of the mean frequency. 
%   Return (for power mode):
%    - mean_bw, mean frequency band containing 95% of the signal's power.
%    - std_bw, standard deviation of frequency band containing 95% of the 
%       signal's power.
%    - mean_flow, mean frequency of the low frequency limit of the band.
%    - std_flow, standard deviation of the low frequency limit of the band.
%    - mean_fhigh, mean frequency of the high frequency limit of the band.
%    - std_high, standard deviation of the high frequency limit of the band.
narginchk(2, 4)

if nargin < 4
    nb_FFT_samples = length(data);
else
    nb_FFT_samples = varargin{2};
end

if nargin < 3
    method = 'FFT';
else
    method = varargin{1};
end

if strcmp(method, 'FFT')
    f = Fs * (0:(round(nb_FFT_samples/2)))/ nb_FFT_samples ;   % Frequencies
    X = abs(fft(data, nb_FFT_samples)/nb_FFT_samples);
    frequency_data = X(1:round(nb_FFT_samples/2) + 1, :);
    frequency_data(2:end-1, :) = 2*frequency_data(2:end-1, :);

    [~, max_ind] = maxk(frequency_data, 2); % Get two highest value indices

    % Remove indices that are at 0 Hz (DC component)
    ind = max_ind(1, :);
    ind(ind == 1) = max_ind(2, ind == 1);

    % Compute mean and std
    varargout{1} = mean(f(ind));
    varargout{2} = std(f(ind));

elseif strcmp(method, 'power')
    % Compute 95% power band for all channels
    [bw, flow, fhigh] = obw(data, Fs, [], 95);

    varargout{1} = mean(bw);
    varargout{2} = std(bw);
    varargout{3} = mean(flow);
    varargout{4} = std(flow);
    varargout{5} = mean(fhigh);
    varargout{6} = std(fhigh);
else
    error("Error: method is invalid, expecting FFT or power");
end

end