%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath(genpath('\MatlabPlugins\fieldtrip')); % path to fieldtrip
addpath funcs\


load('Results\ChangingWindow\baseline_mse.mat')
%load('Results\ChangingWindow\dtw_mse_95.mat')
load('Results\ChangingWindow\dtw_mse_median.mat')
%load('Results\ChangingWindow\dtw_mse_weighted_median.mat')
load('Results\ChangingWindow\frac_peak_mse.mat')
load('Results\ChangingWindow\peak_area_mse.mat')
load('Results\ChangingWindow\peak_lat_mse.mat')
load('Results\ChangingWindow\params.mat')





baseline_mse = fliplr(squeeze(mean(baseline_mse,[4,3,2],'omitnan'))');
%dtw_mse_95 = fliplr(squeeze(mean(dtw_mse_95,[4,3,2],'omitnan'))');
dtw_mse_median = fliplr(squeeze(mean(dtw_mse_median,[4,3,2],'omitnan'))');
%dtw_mse_weighted_median = fliplr(squeeze(mean(dtw_mse_weighted_median,[4,3,2],'omitnan'))');
frac_peak_mse = fliplr(squeeze(mean(frac_peak_mse,[4,3,2],'omitnan'))');
peak_area_mse = fliplr(squeeze(mean(peak_area_mse,[4,3,2],'omitnan'))');
peak_lat_mse = fliplr(squeeze(mean(peak_lat_mse,[4,3,2],'omitnan'))');


snrs = 1./fliplr(params.SNRs);

figure
semilogx(snrs,dtw_mse_median, "LineWidth", 2)
hold on
%semilogx(snrs,dtw_mse_weighted_median, "LineWidth", 2)
%semilogx(snrs,dtw_mse_95, "LineWidth", 2)
semilogx(snrs,baseline_mse, "LineWidth", 2)
semilogx(snrs,frac_peak_mse, "LineWidth", 2)
semilogx(snrs,peak_lat_mse, "LineWidth", 2)
semilogx(snrs,peak_area_mse, "LineWidth", 2)


xlim([snrs(1), snrs(end)])
% add at least 5 xticks
xticks([0.2,0.3,0.4, 0.5,0.75,1,1.5,2,3,5,10])
%fontsize 14
set(gca, 'FontSize', 14)

xlabel('SNRD')
ylabel('MSE')
title('MSE vs SNRD for Different Methods');
legend('DTW Median','Baseline Deviation','Fractional Peak','Peak Latency','Fractional Area','Location','northeastoutside');
set(gcf, 'Position', [0, 0, 1280, 720]);
saveas(gcf,'Results\ChangingWindow\mse_snr.png');


