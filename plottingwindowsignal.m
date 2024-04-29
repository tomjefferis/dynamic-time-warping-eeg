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
baseline_mse = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(baseline_mse, 5)), 4)),1));
dtw_mse_95 = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(dtw_mse_95, 5)), 4)),1));
dtw_mse_median = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(dtw_mse_median, 5)), 4)),1));
dtw_mse_weighted_median = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(dtw_mse_weighted_median, 5)), 4)),1));
frac_peak_mse = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(frac_peak_mse, 5)), 4)),1));
peak_area_mse = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(peak_area_mse, 5)), 4)),1));
peak_lat_mse = squeeze(nanmean(squeeze(nanmean(squeeze(nanmean(peak_lat_mse, 5)), 4)),1));

clims = [min([baseline_mse(:); dtw_mse_95(:); dtw_mse_median(:); dtw_mse_weighted_median(:); frac_peak_mse(:); peak_area_mse(:); peak_lat_mse(:)]), max([baseline_mse(:); dtw_mse_95(:); dtw_mse_median(:); dtw_mse_weighted_median(:); frac_peak_mse(:); peak_area_mse(:); peak_lat_mse(:)])];

% plot on surf, interpolate, no boundaries, view 2, X axis is latency from params.latency_difference, Y axis is window width from params.window_widths
% order plots correctly 
% label plots correctly
% use plot 8 cor colorbar
% set other dimension
% 2d plot roc style curve for increasing snr
figure
subplot(2,4,1)
surf(params.window_widths,params.latency_difference,baseline_mse)
title('baseline_mse')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,2)
surf(params.window_widths,params.latency_difference,dtw_mse_95)
title('dtw_mse_95')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,3)
surf(params.window_widths,params.latency_difference,dtw_mse_median)
title('dtw_mse_median')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,4)
surf(params.window_widths,params.latency_difference,dtw_mse_weighted_median)
title('dtw_mse_weighted_median')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,5)
surf(params.window_widths,params.latency_difference,frac_peak_mse)
title('frac_peak_mse')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,6)
surf(params.window_widths,params.latency_difference,peak_area_mse)
title('peak_area_mse')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)

subplot(2,4,7)
surf(params.window_widths,params.latency_difference,peak_lat_mse)
title('peak_lat_mse')
shading interp
view(2)
ylabel('Latency difference')
xlabel('Window width')
xlim(params.window_widths([1,end-1]))
ylim(params.latency_difference([1,end]))
clim(clims)



