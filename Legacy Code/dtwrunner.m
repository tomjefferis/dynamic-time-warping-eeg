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
num_permutations = 100; % number of times to generate signal per snr level
 

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
    signals1 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_1);
        
        
    signals2 = generate_data(desired_time, desired_fs, SNR_test(i), desired_trials, ...
            desired_participants, desired_jitter, desired_peak_fs,desired_peak_loc_2);


    figure;
    % plot the signals 
    tiledlayout(1, 3);
    ax1 = nexttile;
    plot(signals1{1}.erp,'LineWidth',2,'Color','b')
    hold on
    plot(signals2{1}.erp,'LineWidth',2,'Color','r')
    legend('Signal 1','Signal 2')
    tit = strcat("Example signals @ ", string(SNR_test(i))," NSR");
    title(tit);
    ax2 = nexttile;
    plot(signals1{1}.erp,'LineWidth',2,'Color','b')
    legend('Signal 1')
    tit = strcat("Signal 1 @ ", string(SNR_test(i))," NSR");
    title(tit);
    ax3 = nexttile;
    plot(signals2{1}.erp,'LineWidth',2,'Color','r')
    legend('Signal 2')
    tit = strcat("Signal 2 @ ", string(SNR_test(i))," NSR");
    title(tit);

    % set figure size to current height but width x3
    cur = get(gcf, 'Position');
    set(gcf, 'Position', [cur(1) cur(2) cur(3)*3 cur(4)]);

    tit = strcat("Example_signals_", string(SNR_test(i)),"_NSR",".png");
    saveas(gcf,tit)


    %% Plotting the results, subplots for each metric, histogran for each metric
    figure;
    tiledlayout(2, 4);

    ax1 = nexttile;
    histogram(max_dtw_distances)
    title('Max DTW absoloute distance')
    subtitle(['Middle point: ', num2str(median(max_dtw_distances)),'s'])
    xline(median(max_dtw_distances),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax2 = nexttile;
    histogram(max95_dtw_distances)
    title('95th percentile absoloute DTW distance')
    subtitle(['Middle point: ', num2str(median(max95_dtw_distances)),'s'])
    xline(median(max95_dtw_distances),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax3 = nexttile;
    histogram(iqr_dtw_distances)
    title('75th percentile DTW absoloute distance')
    subtitle(['Middle point: ', num2str(median(iqr_dtw_distances)),'s'])
    xline(median(iqr_dtw_distances),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax4 = nexttile;
    histogram(peak_latency)
    title('Peak latency')
    subtitle(['Middle point: ', num2str(median(peak_latency)),'s'])
    xline(median(peak_latency),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax5 = nexttile;
    histogram(frac_peak_latency)
    title('Fractional peak latency')
    subtitle(['Middle point: ', num2str(median(frac_peak_latency)),'s'])
    xline(median(frac_peak_latency),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax6 = nexttile;
    histogram(area_latency)
    title('50% Fractional Area latency')
    subtitle(['Middle point: ', num2str(median(area_latency)),'s'])
    xline(median(area_latency),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    ax7 = nexttile;
    histogram(area_latency_25)
    title('25% Fractional Area latency')
    subtitle(['Middle point: ', num2str(median(area_latency_25)),'s'])
    xline(median(area_latency_25),'--r','LineWidth',2)
    xline((desired_peak_loc_1 - desired_peak_loc_2), 'g--', 'LineWidth',2)

    linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy')

    lg  = legend('Latency Distribution','Median Latency','Actual latency');
    lg.FontSize = 16;
    lg.Layout.Tile = 8;
    
    tit = strcat("DTW vs other methods latency distribution for ",string(desired_time*1000),"ms signal and ",string(SNR_test(i)),"NSR");
    tite = sgtitle(tit);
    tite.FontSize = 24;
    tite.FontWeight = 'Bold';
    
    set(gcf,'Position',[0 0 2560 1080])
    figname = strcat("Results/DTW_results_dist_",string(desired_time*1000),"ms_signal_",string(SNR_test(i)),".png");
    saveas(gcf,figname)
    
    
end


