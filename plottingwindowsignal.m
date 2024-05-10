%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath(genpath('\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\


%% load data from /Results/changingWindow/
% load baseline_mse
% load dtw_mse_95
% load dtw_mse_median
% load dtw_mse_weighted_median
% load frac_peak_mse
% load peak_area_mse
% load peak_lat_mse
% load params

load('Results\ChangingWindow\baseline_mse.mat')
load('Results\ChangingWindow\dtw_mse_95.mat')
load('Results\ChangingWindow\dtw_mse_median.mat')
load('Results\ChangingWindow\dtw_mse_weighted_median.mat')
load('Results\ChangingWindow\frac_peak_mse.mat')
load('Results\ChangingWindow\peak_area_mse.mat')
load('Results\ChangingWindow\peak_lat_mse.mat')
load('Results\ChangingWindow\params.mat')

% nanmean since some of the arrays have NaNs since not all window locations could be used with long windows
baseline_mse = squeeze(nanmean(squeeze(nanmean(baseline_mse, 4)),1));
dtw_mse_95 = squeeze(nanmean(squeeze(nanmean(dtw_mse_95,  4)),1));
dtw_mse_median = squeeze(nanmean(squeeze(nanmean(dtw_mse_median,  4)),1));
dtw_mse_weighted_median = squeeze(nanmean(squeeze(nanmean(dtw_mse_weighted_median,  4)),1));
frac_peak_mse = squeeze(nanmean(squeeze(nanmean(frac_peak_mse,  4)),1));
peak_area_mse = squeeze(nanmean(squeeze(nanmean(peak_area_mse,  4)),1));
peak_lat_mse = squeeze(nanmean(squeeze(nanmean(peak_lat_mse,  4)),1));

clims = [min([baseline_mse(:); dtw_mse_95(:); dtw_mse_median(:); dtw_mse_weighted_median(:); frac_peak_mse(:); peak_area_mse(:); peak_lat_mse(:)]), max([baseline_mse(:); dtw_mse_95(:); dtw_mse_median(:); dtw_mse_weighted_median(:); frac_peak_mse(:); peak_area_mse(:); peak_lat_mse(:)])];
formatSpec = '%.4f';

% plot on surf, interpolate, no boundaries, view 2, X axis is latency from params.latency_difference, Y axis is window width from params.window_widths
% order plots correctly 
% label plots correctly
% use plot 8 cor colorbar
% set other dimension
% 2d plot roc style curve for increasing snr
figure
subplot(2,4,1)
surf(params.window_widths,params.latency_difference,dtw_mse_median)
title('DTW Median')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
MSE = nanmean(dtw_mse_median(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)


subplot(2,4,2)
surf(params.window_widths,params.latency_difference,dtw_mse_weighted_median)
title('DTW Weighted Median')
shading interp
view(2)
MSE = nanmean(dtw_mse_weighted_median(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,3)
surf(params.window_widths,params.latency_difference,dtw_mse_95)
title('DTW 95th percentile')
shading interp
view(2)
MSE = nanmean(dtw_mse_95(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,4)
surf(params.window_widths,params.latency_difference,baseline_mse)
title('Baseline Deviation')
shading interp
view(2)
MSE = nanmean(baseline_mse(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,5)
surf(params.window_widths,params.latency_difference,frac_peak_mse)
title('Fractional Peak Latency')
shading interp
view(2)
MSE = nanmean(frac_peak_mse(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,6)
surf(params.window_widths,params.latency_difference,peak_lat_mse)
title('Peak Latency')
shading interp
view(2)
MSE = nanmean(peak_lat_mse(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,7)
surf(params.window_widths,params.latency_difference,peak_area_mse)
title('Fractional Area Latency')
shading interp
view(2)
MSE = nanmean(peak_area_mse(:));
subtitle(['Average MSE: ', num2str(MSE,formatSpec)])
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

% plot 8 just colorbar
subplot(2,4,8)
clim(clims)
colorbar
axis off

% figure size 1920x1080
set(gcf, 'Position', [0, 0, 1920, 1080])

% save figure
saveas(gcf, 'Results\ChangingWindow\plottingwindowsignal.png')

load('Results\ChangingWindow\baseline_mse.mat')
load('Results\ChangingWindow\dtw_mse_95.mat')
load('Results\ChangingWindow\dtw_mse_median.mat')
load('Results\ChangingWindow\dtw_mse_weighted_median.mat')
load('Results\ChangingWindow\frac_peak_mse.mat')
load('Results\ChangingWindow\peak_area_mse.mat')
load('Results\ChangingWindow\peak_lat_mse.mat')
load('Results\ChangingWindow\params.mat')





baseline_mse = fliplr(squeeze(mean(baseline_mse,[4,3,2],'omitnan'))');
dtw_mse_95 = fliplr(squeeze(mean(dtw_mse_95,[4,3,2],'omitnan'))');
dtw_mse_median = fliplr(squeeze(mean(dtw_mse_median,[4,3,2],'omitnan'))');
dtw_mse_weighted_median = fliplr(squeeze(mean(dtw_mse_weighted_median,[4,3,2],'omitnan'))');
frac_peak_mse = fliplr(squeeze(mean(frac_peak_mse,[4,3,2],'omitnan'))');
peak_area_mse = fliplr(squeeze(mean(peak_area_mse,[4,3,2],'omitnan'))');
peak_lat_mse = fliplr(squeeze(mean(peak_lat_mse,[4,3,2],'omitnan'))');


snrs = 1./fliplr(params.SNRs);

figure
semilogx(snrs,dtw_mse_median, "LineWidth", 2)
hold on
semilogx(snrs,dtw_mse_weighted_median, "LineWidth", 2)
semilogx(snrs,dtw_mse_95, "LineWidth", 2)
semilogx(snrs,baseline_mse, "LineWidth", 2)
semilogx(snrs,frac_peak_mse, "LineWidth", 2)
semilogx(snrs,peak_lat_mse, "LineWidth", 2)
semilogx(snrs,peak_area_mse, "LineWidth", 2)


xlim([snrs(1), snrs(end)])
% add at least 5 xticks
xticks([0.2,0.3,0.4, 0.5,0.75,1,1.5,2,3,5,10])
%fontsize 14
set(gca, 'FontSize', 14)

xlabel('SNR')
ylabel('MSE')
title('MSE vs SNR for Different Methods');
legend('DTW Median','DTW Weighted Median','DTW 95th Percentile','Baseline Deviation','Fractional Peak','Peak Latency','Fractional Area','Location','northeastoutside');
set(gcf, 'Position', [0, 0, 1280, 720]);
saveas(gcf,'Results\ChangingWindow\mse_snr.png');