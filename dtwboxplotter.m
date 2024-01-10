%% EEG pattern glare analysis - Author: Tom Jefferis
%% This file is used for running DTW on the EEG data
%% setting up paths to plugins and default folder
clear all;
restoredefaultpath;
addpath funcs/

%% Parameters of this analysis
SNR_test = [0.1:0.1:0.9];
desired_peak_loc_1 = 0.1; % in seconds
desired_peak_loc_2 = 0.2; % in seconds
desired_time = 0.5; % in seconds
num_permutations = 10000; % number of times to generate signal per snr level
 

% parameters of synthetic signal
desired_fs = 500; % sample rate in Hz
desired_trials = 1; % number of trials per participant to generate
desired_participants = 1; % number of participants to generate
desired_jitter = 0; % jitter in ± ms 
desired_peak_fs = 5; % frequency of peak in Hz
%Controls where the peak is placed in seconds


for i = 1:length(SNR_test)
    iqr_dtw_distances = zeros(num_permutations,1);
    max_dtw_distances = zeros(num_permutations,1);
    max95_dtw_distances = zeros(num_permutations,1);
    peak_latency = zeros(num_permutations,1);
    frac_peak_latency = zeros(num_permutations,1);
    area_latency = zeros(num_permutations,1);
    area_latency_25 = zeros(num_permutations,1);


    for j = 1:num_permutations
        signals1 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_1);
        
        
        signals2 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_2);

        
        [iqr_dtw_distances(j),max_dtw_distances(j),max95_dtw_distances(j)] = dynamictimewarper(signals1,signals2,desired_fs);
        [peak_latency(j)] = peaklatency(signals1,signals2, desired_fs);
        [frac_peak_latency(j)] = fracpeaklatency(signals1,signals2, desired_fs);
        [area_latency(j)] = peakArea(signals1,signals2, desired_fs, 0.5);
        [area_latency_25(j)] = peakArea(signals1,signals2, desired_fs, 0.25);

    end


    %figure;
    %% plot the signals 
    %tiledlayout(1, 3);
    %ax1 = nexttile;
    %plot(signals1{1}.erp,'LineWidth',2,'Color','b')
    %hold on
    %plot(signals2{1}.erp,'LineWidth',2,'Color','r')
    %legend('Signal 1','Signal 2')
    %tit = strcat("Example signals @ ", string(SNR_test(i))," NSR");
    %title(tit);
    %ax2 = nexttile;
    %plot(signals1{1}.erp,'LineWidth',2,'Color','b')
    %legend('Signal 1')
    %tit = strcat("Signal 1 @ ", string(SNR_test(i))," NSR");
    %title(tit);
    %ax3 = nexttile;
    %plot(signals2{1}.erp,'LineWidth',2,'Color','r')
    %legend('Signal 2')
    %tit = strcat("Signal 2 @ ", string(SNR_test(i))," NSR");
    %title(tit);

    %% set figure size to current height but width x3
    %cur = get(gcf, 'Position');
    %set(gcf, 'Position', [cur(1) cur(2) cur(3)*3 cur(4)]);

    %tit = strcat("Example_signals_", string(SNR_test(i)),"_NSR",".png");
    %saveas(gcf,tit)


    %% Plotting the results, subplots for each metric, histogran for each metric
    figure;
    data = [iqr_dtw_distances, max_dtw_distances, max95_dtw_distances, peak_latency, frac_peak_latency, area_latency, area_latency_25];
    labels = {'75th percentile DTW', 'Max DTW', '95th percentile DTW', 'Peak Latency', 'Fractional Peak Latency', '50% Fractional Area', '25% Fractional Area'};
    
    boxchart(data);
    set(gca,'XTickLabel',labels);
    tit = strcat("DTW vs other methods latency distribution @ ",string(SNR_test(i))," NSR");
    title(tit);
    xlabel('Methods');
    ylabel('Latency (s)');
    yline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)
    legend("","Actual Latency");
    set(gca, 'FontSize', 12);
    set(gcf, 'Position', [0 0 2560 1080]);
    figname = strcat("DTW_results_boxplot_", string(desired_time*1000), "ms_signal_", string(SNR_test(i)), ".png");
    saveas(gcf, figname);
    
    
end


