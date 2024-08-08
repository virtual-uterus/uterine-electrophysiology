function powerPlot(signal, Fs, time_res)
%POWERPLOT Uses the waterfall function to plot the power of the signal.
%
%   Input:
%    - signal, signal to plot, signal(NB_SAMPLES x CHANNELS).
%    - Fs, sampling frequency.
%    - time_res, temporal resolution for the spectrogram.
%
%   Return:
[pow, f, t] = pspectrum(signal, Fs, 'spectrogram', 'TimeResolution', time_res);

waterfall(f,t,pow')
xlabel('Frequency (Hz)')
ylabel('Time (seconds)')
wtf = gca;
wtf.XDir = 'reverse';
view([30 45])
end