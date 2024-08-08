[data, tvec, Fs, electrode_cnfg] = loadExptData("/home/mroe734/Documents/phd/electrophys/uterus/data/AWB004/mat/AWB004_run_2_G7x2_no_marks.mat", 30);
close all;
[fwave, swave] = separateWaves(data, 1, 0.25, Fs);
reshaped_swave = zeros(size(data, 1), size(electrode_cnfg, 1), size(electrode_cnfg, 2));
reshaped_fwave = zeros(size(data, 1), size(electrode_cnfg, 1), size(electrode_cnfg, 2));

for j = 1:size(swave, 2)
    [l, m] = ind2sub(size(electrode_cnfg), j);
    reshaped_fwave(:, l, m) = fwave(:, j) ./ abs(max(abs(fwave(:, j))));
    reshaped_swave(:, l, m) = swave(:, j) ./ abs(max(abs(swave(:, j))));
end

figure;
tiledlayout(1, 4);

for j = 1:4
    nexttile
    imagesc(reshaped_swave(:, :, j)');
end
%%
degradation_factor = 50;
degradation = 1:degradation_factor:length(mean_swave); 

mean_swave = squeeze(mean(reshaped_swave, 2));
% mean_swave = mean_swave ./ abs(max(abs(mean_swave)));
figure; 
tiledlayout(2, 1);
nexttile;
plot(tvec, mean_swave);
xlim([tvec(1), tvec(end)])

nexttile;
imagesc(mean_swave');

mean_fwave = squeeze(mean(reshaped_fwave, 2));
[fw_upper, ~] = envelope(mean_fwave, 300, 'rms');
% fw_upper = fw_upper ./ abs(max(abs(fw_upper)));
figure;
tiledlayout(2, 1);
nexttile;
plot(tvec, fw_upper);
xlim([tvec(1), tvec(end)])

nexttile;
imagesc(fw_upper');

figure;
surf(tvec(degradation), 1:4, mean_swave(degradation, :)');
