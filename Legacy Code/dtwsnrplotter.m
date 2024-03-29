%% EEG pattern glare analysis - Author: Tom Jefferis
%% This file is used for running DTW on the EEG data
%% setting up paths to plugins and default folder
clear all;
restoredefaultpath;
addpath funcs/

%% Parameters of this analysis
SNR_test = [0.1:0.1:0.9];
desired_peak_loc_1 = 0.15; % in seconds
desired_peak_loc_2 = 0.17; % in seconds
desired_time = 0.25; % in seconds
num_permutations = 100; % number of times to generate signal per snr level


% parameters of synthetic signal
desired_fs = 500; % sample rate in Hz
desired_noise_level = 0.1; % SNR ratio
desired_trials = 1; % number of trials per participant to generate
desired_participants = 1; % number of participants to generate
desired_jitter = 0; % jitter in ± ms 
desired_peak_fs = 5; % frequency of peak in Hz
%Controls where the peak is placed in seconds

baseline = round(((min(desired_peak_loc_1, desired_peak_loc_2)-((1/desired_peak_fs)/2))) * desired_fs);

iqr_dtw_distances = zeros(length(SNR_test),1);
max_dtw_distances = zeros(num_permutations,length(SNR_test));
max95_dtw_distances = zeros(num_permutations,length(SNR_test));
peak_latency = zeros(num_permutations,length(SNR_test));
frac_peak_latency = zeros(num_permutations,length(SNR_test));
area_latency = zeros(num_permutations,length(SNR_test));
baseline_dev = zeros(num_permutations,length(SNR_test));


for i = 1:length(SNR_test)
    for j = 1:num_permutations
        signals1 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_1);
        
        
        signals2 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_2);
    
         
        [iqr_dtw_distances(j,i),max_dtw_distances(j,i),max95_dtw_distances(j,i)] = dynamictimewarper(signals1,signals2,desired_fs);
        [peak_latency(j,i)] = peaklatency(signals1,signals2, desired_fs);
        [frac_peak_latency(j,i)] = fracpeaklatency(signals1,signals2, desired_fs);
        [area_latency(j,i)] = peakArea(signals1,signals2, desired_fs, 0.5,baseline);
        [baseline_dev(j,i)] = baselineDeviation(signals1,signals2, desired_fs, baseline, 2);
    
    end
end

% Calculate standard deviation for error bars
std_iqr_dtw_distances = std(iqr_dtw_distances, 1);
std_max_dtw_distances = std(max_dtw_distances, 1);
std_max95_dtw_distances = std(max95_dtw_distances, 1);
std_peak_latency = std(peak_latency, 1);
std_frac_peak_latency = std(frac_peak_latency, 1);
std_area_latency = std(area_latency, 1);
std_baseline_dev = std(baseline_dev, 1);

iqr_dtw_distances = median(iqr_dtw_distances,1);
max_dtw_distances = median(max_dtw_distances,1);
max95_dtw_distances = median(max95_dtw_distances,1);
peak_latency = median(peak_latency,1);
frac_peak_latency = median(frac_peak_latency,1);
area_latency = median(area_latency,1);
baseline_dev = median(baseline_dev,1);

%% Plotting the results, subplot for each line with X bing SNR and Y being the DTW distance
figure;
tiledlayout(2,4);

ax1 = nexttile;
errorbar(SNR_test, iqr_dtw_distances, std_iqr_dtw_distances, 'LineWidth', 2)
hold on
yline(mean(iqr_dtw_distances),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('TESTING pathlength*fs*std DTW')
subtitle("Average latency = " + mean(iqr_dtw_distances) + "ms")
xlabel('NSR')
ylabel('DTW distance (ms)')

ax4 = nexttile;
errorbar(SNR_test, max_dtw_distances, std_max_dtw_distances, 'LineWidth', 2)
hold on
yline(mean(max_dtw_distances),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('Max DTW distance')
subtitle("Average latency = " + mean(max_dtw_distances) + "ms")
xlabel('NSR')
ylabel('DTW distance (ms)')

ax5 = nexttile;
errorbar(SNR_test, max95_dtw_distances, std_max95_dtw_distances, 'LineWidth', 2)
hold on
yline(mean(max95_dtw_distances),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('95th Percentile DTW distance')
subtitle("Average latency = " + mean(max95_dtw_distances) + "ms")
xlabel('NSR')
ylabel('DTW distance (ms)')

ax6 = nexttile;
errorbar(SNR_test, peak_latency, std_peak_latency, 'LineWidth', 2)
hold on
yline(mean(peak_latency),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('Peak latency')
subtitle("Average latency = " + mean(peak_latency) + "ms")
xlabel('NSR')
ylabel('Peak latency (ms)')

ax7 = nexttile;
errorbar(SNR_test, frac_peak_latency, std_frac_peak_latency, 'LineWidth', 2)
hold on
yline(mean(frac_peak_latency),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('Fractional peak latency')
subtitle("Average latency = " + mean(frac_peak_latency) + "ms")
xlabel('NSR')
ylabel('Fractional peak latency (ms)')

ax2 = nexttile;
errorbar(SNR_test, area_latency, std_area_latency, 'LineWidth', 2)
hold on
yline(mean(area_latency),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('50% Fractional area latency')
subtitle("Average latency = " + mean(area_latency) + "ms")
xlabel('NSR')
ylabel('DTW distance (ms)')

ax3 = nexttile;
errorbar(SNR_test, baseline_dev, std_baseline_dev, 'LineWidth', 2)
hold on
yline(mean(baseline_dev),'r--', 'LineWidth',2)
yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
title('Baseline deviation latency')
subtitle("Average latency = " + mean(baseline_dev) + "ms")
xlabel('NSR')
ylabel('DTW distance (ms)')

% set y axis to be the same for all tiles
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'y')
ylim1 = ylim(ax1);
ylim([ylim1(1) ylim1(2)]);

lg  = legend('Latency','Mean Latency','Actual latency');
lg.FontSize = 16;
lg.Layout.Tile = 8;

tit = strcat("DTW vs other methods for varying NSR levels for ",string(desired_time*1000),"ms signal");
sgt = sgtitle(tit);
sgt.FontSize = 24;
sgt.FontWeight = 'Bold';

set(gcf,'Position',[0 0 1280 480])
figname = strcat("Results/DTW_results_NSR_",string(desired_time*1000),"ms_signal.png");
saveas(gcf,figname)



