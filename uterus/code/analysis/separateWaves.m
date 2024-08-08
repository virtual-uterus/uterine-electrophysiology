function [fast_wave, slow_wave] = separateWaves(data, fw_range, sw_range, Fs)
%SEPARATEWAVES Filters the given data into a fast wave and a slow wave.
%
%   The slow wave is extracted either with a bandpass filter or a lowpass
%   filter depending on the size of sw_range. The fast wave is extracted
%   with a bandpass or a highpass filter depending on the size of fw_range.
%
%   Input:
%    - data, data to process. Data can be a vector or a matrix. If data is a
%   matrix, the filtering is done along the columns, 
%   data(SAMPLES x NB_CHANNELS)
%    - fw_range, frequency band in Hz for fast wave. Fw_range can be a scalar
%   or a vector. If fw_range is scalar then data is filtered with a
%   highpass filter, otherwise with a bandpass filter.
%    - sw_range, frequency band in Hz for slow wave. Sw_range can be a scalar
%   or a vector. If sw_range is scalar then data is filtered with a lowpass
%   filter, otherwise with a bandpass filter.
%    - Fs, sampling frequency
%
%   Return:
%    - fast_wave, extracted fast wave, fast_wave(SAMPLES x NB_CHANNELS). 
%    - slow_wave, extracted slow wave, slow_wave(SAMPLES x NB_CHANNELS).
if isscalar(fw_range)
    fast_wave = highpass(data, fw_range, Fs);

else
    fast_wave = bandpass(data, fw_range, Fs);
end

if isscalar(sw_range)
    slow_wave = lowpass(data, sw_range, Fs);
    
else
    slow_wave = bandpass(data, sw_range, Fs);
end

end

