%% EEG pattern glare analysis - Author: Tom Jefferis
%% This file is used for running DTW on the EEG data
%% setting up paths to plugins and default folder
clear all;
restoredefaultpath;

%% Parameters of this analysis
desired_noise_level = 0.5; % signal to noise ratio
num_permutations = 1000; % number of times to generate signal per snr level
latencyDiff = -0.1:0.01:0.1; % signal lengths to test in seconds
desired_time = 0.5; % latency difference between signals in seconds

% parameters of synthetic signal
desired_fs = 500; % sample rate in Hz
desired_trials = 1; % number of trials per participant to generate
desired_participants = 1; % number of participants to generate
desired_jitter = 0; % jitter in ± ms 
desired_peak_fs = 10; % frequency of peak in Hz
%Controls where the peak is placed in seconds


iqr_dtw_distances = zeros(length(latencyDiff),1);
max_dtw_distances = zeros(num_permutations,length(latencyDiff));
max95_dtw_distances = zeros(num_permutations,length(latencyDiff));
peak_latency = zeros(num_permutations,length(latencyDiff));
frac_peak_latency = zeros(num_permutations,length(latencyDiff));
area_latency = zeros(num_permutations,length(latencyDiff));
baseline_dev = zeros(num_permutations,length(latencyDiff));


for i = 1:length(latencyDiff)
    for j = 1:num_permutations

        
        while true
            desired_peak_loc_1 = rand(1)*(desired_time*0.65);
            desired_peak_loc_2 = desired_peak_loc_1 + latencyDiff(i);
            
            if desired_peak_loc_2 <= desired_time*0.75
                break; % Exit the loop if the peak location is within the signal length
            end
        end

        baseline = round(((min(desired_peak_loc_1, desired_peak_loc_2)-((1/desired_peak_fs)/2))) * desired_fs);

        if baseline < 5
            baseline = 5;
        end


        try
            signals1 = generate_data(desired_time, desired_fs, desired_noise_level, desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_1);
        
        
            signals2 = generate_data(desired_time, desired_fs, desired_noise_level, desired_trials, ...
                desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_2);
        catch exception
            print(exception)
        end
    
         
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
errorbar(latencyDiff, iqr_dtw_distances, std_iqr_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(iqr_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('TESTING pathlength*fs*std DTW')
subtitle("Average latency = " + mean(iqr_dtw_distances) + "ms")
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax4 = nexttile;
errorbar(latencyDiff, max_dtw_distances, std_max_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(max_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('Max DTW distance')
subtitle("Average latency = " + mean(max_dtw_distances) + "ms")
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax5 = nexttile;
errorbar(latencyDiff, max95_dtw_distances, std_max95_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(max95_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('95th Percentile DTW distance')
subtitle("Average latency = " + mean(max95_dtw_distances) + "ms")
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax6 = nexttile;
errorbar(latencyDiff, peak_latency, std_peak_latency, 'LineWidth', 2)
hold on
%yline(mean(peak_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('Peak latency')
subtitle("Average latency = " + mean(peak_latency) + "ms")
xlabel('Latency Difference (S)')
ylabel('Peak latency (ms)')

ax7 = nexttile;
errorbar(latencyDiff, frac_peak_latency, std_frac_peak_latency, 'LineWidth', 2)
hold on
%yline(mean(frac_peak_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('Fractional peak latency')
subtitle("Average latency = " + mean(frac_peak_latency) + "ms")
xlabel('Latency Difference (S)')
ylabel('Fractional peak latency (ms)')

ax2 = nexttile;
errorbar(latencyDiff, area_latency, std_area_latency, 'LineWidth', 2)
hold on
%yline(mean(area_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('50% Fractional area latency')
subtitle("Average latency = " + mean(area_latency) + "ms")
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax3 = nexttile;
errorbar(latencyDiff, baseline_dev, std_baseline_dev, 'LineWidth', 2)
hold on
%yline(mean(baseline_dev),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(-1*latencyDiff,latencyDiff,'r--', 'LineWidth',2)
title('Baseline deviation latency')
subtitle("Average latency = " + mean(baseline_dev) + "ms")
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

% set y axis to be the same for all tiles
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy')
ylim1 = ylim(ax1);
ylim([ylim1(1) ylim1(2)]);
xlim1 = xlim(ax1);
xlim([latencyDiff(1) latencyDiff(end)]);

lg  = legend('Latency','Actual latency');
lg.FontSize = 16;
lg.Layout.Tile = 8;

tit = strcat("DTW vs other methods for different latency differences");
sgt = sgtitle(tit);
sgt.FontSize = 24;
sgt.FontWeight = 'Bold';

set(gcf,'Position',[0 0 1280 480])
figname = strcat("Results/DTW_results_latencyChange",string(desired_time*1000),"ms_signal.png");
saveas(gcf,figname)



