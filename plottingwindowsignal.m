%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
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

load('W:\PhD\Results\changingWindow\baseline_mse.mat')
load('W:\PhD\Results\changingWindow\dtw_mse_95.mat')
load('W:\PhD\Results\changingWindow\dtw_mse_median.mat')
load('W:\PhD\Results\changingWindow\dtw_mse_weighted_median.mat')
load('W:\PhD\Results\changingWindow\frac_peak_mse.mat')
load('W:\PhD\Results\changingWindow\peak_area_mse.mat')
load('W:\PhD\Results\changingWindow\peak_lat_mse.mat')
load('W:\PhD\Results\changingWindow\params.mat')

% nanmean last 2 dimensions
baseline_mse = squeeze(nanmean(squeeze(nanmean(baseline_mse, 5)), 4));
dtw_mse_95 = squeeze(nanmean(squeeze(nanmean(dtw_mse_95, 5)), 4));
dtw_mse_median = squeeze(nanmean(squeeze(nanmean(dtw_mse_median, 5)), 4));
dtw_mse_weighted_median = squeeze(nanmean(squeeze(nanmean(dtw_mse_weighted_median, 5)), 4));
frac_peak_mse = squeeze(nanmean(squeeze(nanmean(frac_peak_mse, 5)), 4));
peak_area_mse = squeeze(nanmean(squeeze(nanmean(peak_area_mse, 5)), 4));
peak_lat_mse = squeeze(nanmean(squeeze(nanmean(peak_lat_mse, 5)), 4));

% plot on surf, interpolate, no boundaries, view 2, X axis is latency from params.latency_difference, Y axis is window width from params.window_widths
figure
subplot(2,4,1)
surf(params.latency_difference,params.window_widths,baseline_mse)
title('baseline_mse')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,2)
surf(params.latency_difference,params.window_widths,dtw_mse_95)
title('dtw_mse_95')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,3)
surf(params.latency_difference,params.window_widths,dtw_mse_median)
title('dtw_mse_median')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,4)
surf(params.latency_difference,params.window_widths,dtw_mse_weighted_median)
title('dtw_mse_weighted_median')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,5)
surf(params.latency_difference,params.window_widths,frac_peak_mse)
title('frac_peak_mse')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,6)
surf(params.latency_difference,params.window_widths,peak_area_mse)
title('peak_area_mse')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')

subplot(2,4,7)
surf(params.latency_difference,params.window_widths,peak_lat_mse)
title('peak_lat_mse')
shading interp
view(2)
xlabel('Latency difference')
ylabel('Window width')



