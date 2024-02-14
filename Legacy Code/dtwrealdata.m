clear all
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
addpath generate_signals/
addpath funcs/

%% Config
desired_noise = 0.2; %Noise to be overlayed on the signal
offset = [0.01:0.01:0.5]; %Latency offset of the signals
num_permutations = 1000; %Number of permutations to be performed



%% loading data
load('grandavg.mat') % grand average for medium stimuli from pattern glare experiment

cfg = [];
cfg.baseline = [-0.5 0];
cfg.baselinetype = 'db';
cfg.parameter = 'avg';

grandavg = ft_timelockbaseline(cfg, x); % Gets Oz and baseline corrects
signal = grandavg.avg(23,:);
time = grandavg.time;
fs = 1/mean(diff(time));

iqr_dtw_distances = zeros(num_permutations,length(offset));
max_dtw_distances = zeros(num_permutations,length(offset));
max95_dtw_distances = zeros(num_permutations,length(offset));
peak_latency = zeros(num_permutations,length(offset));
frac_peak_latency = zeros(num_permutations,length(offset));
area_latency = zeros(num_permutations,length(offset));
area_latency_25 = zeros(num_permutations,length(offset));


for i = 1:length(offset)

    signal1 = signal;
    signal2 = [signal(round(offset(i)*fs):end), zeros(1,(length(signal)-length(signal(round(offset(i)*fs):end))))];

    baseline = fs*abs(cfg.baseline(1)) - (length(signal)-length(signal(round(offset(i)*fs):end)));


    for j = 1:num_permutations

        noise1 = noise(length(signal1), 1, fs);
        noise2 = noise(length(signal2), 1, fs);

        signal1 = signal1 + noise1*desired_noise;
        signal2 = signal2 + noise2*desired_noise;

        signals1{1}.erp = signal1';
        signals2{1}.erp = signal2';

        [iqr_dtw_distances(j,i),max_dtw_distances(j,i),max95_dtw_distances(j,i)] = dynamictimewarper(signals1,signals2,fs);
        [peak_latency(j,i)] = peaklatency(signals1,signals2, fs);
        [frac_peak_latency(j,i)] = fracpeaklatency(signals1,signals2, fs);
        [area_latency(j,i)] = peakArea(signals1,signals2, fs, 0.5,baseline);
        [baseline_dev(j,i)] = baselineDeviation(signals1,signals2, fs, baseline, 2);


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

% find the accuracy of each method
accuracy_iqr = abs(((offset - iqr_dtw_distances).^2));
accuracy_max = abs(((offset - max_dtw_distances).^2));
accuracy_max95 = abs(((offset - max95_dtw_distances).^2));
accuracy_peak = abs(((offset - peak_latency).^2));
accuracy_frac_peak = abs(((offset - frac_peak_latency).^2));
accuracy_area = abs(((offset - area_latency).^2));
accuracy_baseline = abs(((offset - baseline_dev).^2));


%% Plotting the results, subplot for each line with X bing SNR and Y being the DTW distance
figure;
tiledlayout(2,4);

ax1 = nexttile;
errorbar(offset, iqr_dtw_distances, std_iqr_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(iqr_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('TESTING pathlength*fs*std DTW')
subtitle("Squared Distance: " + mean(accuracy_iqr) )
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax4 = nexttile;
errorbar(offset, max_dtw_distances, std_max_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(max_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('Max DTW distance')
subtitle("Squared Distance: " + mean(accuracy_max) )
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax5 = nexttile;
errorbar(offset, max95_dtw_distances, std_max95_dtw_distances, 'LineWidth', 2)
hold on
%yline(mean(max95_dtw_distances),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('95th Percentile DTW distance')
subtitle("Squared Distance: " + mean(accuracy_max95) )
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax6 = nexttile;
errorbar(offset, peak_latency, std_peak_latency, 'LineWidth', 2)
hold on
%yline(mean(peak_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('Peak latency')
subtitle("Squared Distance: " + mean(accuracy_peak) )
xlabel('Latency Difference (S)')
ylabel('Peak latency (ms)')

ax7 = nexttile;
errorbar(offset, frac_peak_latency, std_frac_peak_latency, 'LineWidth', 2)
hold on
%yline(mean(frac_peak_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('Fractional peak latency')
subtitle("Squared Distance: " + mean(accuracy_frac_peak) )
xlabel('Latency Difference (S)')
ylabel('Fractional peak latency (ms)')

ax2 = nexttile;
errorbar(offset, area_latency, std_area_latency, 'LineWidth', 2)
hold on
%yline(mean(area_latency),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('50% Fractional area latency')
subtitle("Squared Distance: " + mean(accuracy_area) )
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

ax3 = nexttile;
errorbar(offset, baseline_dev, std_baseline_dev, 'LineWidth', 2)
hold on
%yline(mean(baseline_dev),'r--', 'LineWidth',2)
%yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
plot(offset,offset,'r--', 'LineWidth',2)
title('Baseline deviation latency')
subtitle("Squared Distance: " + mean(accuracy_baseline) )
xlabel('Latency Difference (S)')
ylabel('DTW distance (ms)')

% set y axis to be the same for all tiles
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy')
%ylim1 = ylim(ax1);
%ylim([ylim1(1) ylim1(2)]);
xlim1 = xlim(ax1);
xlim([offset(1) offset(end)]);

lg  = legend('Latency','Actual latency');
lg.FontSize = 16;
lg.Layout.Tile = 8;

tit = strcat("DTW vs other methods for different latency differences");
sgt = sgtitle(tit);
sgt.FontSize = 24;
sgt.FontWeight = 'Bold';

set(gcf,'Position',[0 0 1920 720])
figname = strcat("Results/real_world_data_signal.png");
saveas(gcf,figname)






