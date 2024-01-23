%% EEG pattern glare analysis - Author: Tom Jefferis
%% This file is used for running DTW on the EEG data
%% setting up paths to plugins and default folder
clear all;
restoredefaultpath;
addpath funcs/;
addpath generate_signals/;


SNR = 0.8; % signal to noise ratio
num_permutations = 100; % number of times to generate signal per snr level
signalLens = [0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]; % signal lengths to test in seconds
latencyDiffs = -0.1:0.01:0.1; % latency difference between signals in seconds
fs = 1000; % sampling frequency
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds


iqr_dtw_distances = zeros(num_permutations,length(signalLens), length(latencyDiffs));
max_dtw_distances = zeros(num_permutations, length(signalLens), length(latencyDiffs));
max95_dtw_distances = zeros(num_permutations, length(signalLens), length(latencyDiffs));
peak_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
frac_peak_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
area_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
baseline_dev = zeros(num_permutations, length(signalLens), length(latencyDiffs));

baselineFun = 0;

for i = 1:length(signalLens)
    signalLen = signalLens(i);

    if (baseline > signalLen/4) 
        baselineFun = signalLen*0.1;
    else
        baselineFun = baseline;
    end

    signalLen = signalLen - baselineFun;

    for j = 1:length(latencyDiffs)
        latencyDiff = latencyDiffs(j);
        
        for k = 1:num_permutations


            [sig1, sig2] = ERPGenerate(signalLen, fs, variance, SNR, baselineFun, latencyDiff);

           

            baselines = baselineFun*fs;

            [iqrDist,maxDist,max95Dist] = dynamictimewarper(sig1,sig2,fs);
            peakLat = peaklatency(sig1,sig2,fs);
            fracPeakLat = fracpeaklatency(sig1,sig2,fs);
            areaLat = peakArea(sig1,sig2,fs, 0.5, baselines);
            baselineLat = baselineDeviation(sig1,sig2,fs, baselines,2);


            % Gives the error in the latency difference between method and actual
            iqr_dtw_distances(k,i,j) = iqrDist - latencyDiff;
            max_dtw_distances(k,i,j) = maxDist - latencyDiff;
            max95_dtw_distances(k,i,j) = max95Dist - latencyDiff;
            peak_latency(k,i,j) = peakLat - latencyDiff;
            frac_peak_latency(k,i,j) = fracPeakLat - latencyDiff;
            area_latency(k,i,j) = areaLat - latencyDiff;
            baseline_dev(k,i,j) = baselineLat - latencyDiff;
            
        end
    end

end

% calculate MSE for each method
iqr_dtw_mse = squeeze(mean(iqr_dtw_distances.^2,1));
max_dtw_mse = squeeze(mean(max_dtw_distances.^2,1));
max95_dtw_mse = squeeze(mean(max95_dtw_distances.^2,1));
peak_latency_mse = squeeze(mean(peak_latency.^2,1));
frac_peak_latency_mse = squeeze(mean(frac_peak_latency.^2,1));
area_latency_mse = squeeze(mean(area_latency.^2,1));
baseline_dev_mse = squeeze(mean(baseline_dev.^2,1));

maxcolor = max([max(iqr_dtw_mse(:)), max(max_dtw_mse(:)), max(max95_dtw_mse(:)), max(peak_latency_mse(:)), max(frac_peak_latency_mse(:)), max(area_latency_mse(:)), max(baseline_dev_mse(:))]);
mincolor = 0;

% subplots 2,4 with surf plots view 2 
figure();
ax1 = subplot(2,4,1);
surf(latencyDiffs, signalLens, iqr_dtw_mse);
title('Median DTW');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(iqr_dtw_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);

ax2 = subplot(2,4,2);
surf(latencyDiffs, signalLens, max_dtw_mse);
title('Max DTW');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(max_dtw_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);

ax3 = subplot(2,4,3);
surf(latencyDiffs, signalLens, max95_dtw_mse);
title('Max 95% DTW');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(max95_dtw_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);

ax4 = subplot(2,4,4);
surf(latencyDiffs, signalLens, peak_latency_mse);
title('Peak Latency');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(peak_latency_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);

ax5 = subplot(2,4,5);
surf(latencyDiffs, signalLens, frac_peak_latency_mse);
title('Fractional Peak Latency');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(frac_peak_latency_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);

ax6 = subplot(2,4,6);
surf(latencyDiffs, signalLens, area_latency_mse);
title('Area Latency');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
clim([mincolor maxcolor]);
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(area_latency_mse(:)));
subtitle(subtitles);
clim([mincolor maxcolor]);


ax7 = subplot(2,4,7);
surf(latencyDiffs, signalLens, baseline_dev_mse);
title('Baseline Deviation');
xlabel('Latency Difference (s)');
ylabel('Signal Length (s)');
zlabel('MSE');
view(2);
shading interp;
subtitles = sprintf('Average MSE: %.4f', mean(baseline_dev_mse(:)));
subtitle(subtitles);

clim([mincolor maxcolor]);

% shared colourbar and axis limits
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');
ylim([signalLens(1) signalLens(end)]);
h = colorbar;
clim([mincolor maxcolor]);
ylabel(h, 'MSE');
set(h, 'Position', [.92 .11 .02 .8150]);
set(gcf, 'Position', [0 0 2000 1000]); % Increase the figure size
set(gca, 'ZLim', [0 0.1]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);


