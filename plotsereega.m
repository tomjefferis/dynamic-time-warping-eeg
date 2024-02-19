% load data
load('Results\data\dtw_mse_median.mat')
load('Results\data\dtw_mse_weighted_median.mat')
load('Results\data\dtw_mse_95.mat')
load('Results\data\baseline_mse.mat')
load('Results\data\frac_peak_mse.mat')
load('Results\data\peak_lat_mse.mat')
load('Results\data\peak_area_mse.mat')

latency_difference = -0.05:0.01:0.05;
n_components = 1:8;
sig_length = 0.3:0.2:3; % time in S
% first dim is N-comonents
% second dim is length of signal
% third dim is latency difference
% fourth dim is num_permutations
% values are MSE for each permutation




% plot grid of subplots for each possible 3d slice of the data
% create surf plots with interp shading, first set should contain 
% x should be latency difference, y should be number of components, z should be MSE (averaged)

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,2),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,2),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,2),4));
baseline_mse_p1 = squeeze(mean(mean(baseline_mse,2),4));
frac_peak_mse_p1 = squeeze(mean(mean(frac_peak_mse,2),4));
peak_lat_mse_p1 = squeeze(mean(mean(peak_lat_mse,2),4));
peak_area_mse_p1 = squeeze(mean(mean(peak_area_mse,2),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:); baseline_mse_p1(:); frac_peak_mse_p1(:); peak_lat_mse_p1(:); peak_area_mse_p1(:)]);


figure();
ax1 = subplot(2,4,1);
surf(latency_difference,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(2,4,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(2,4,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);


ax4 = subplot(2,4,4);
surf(latency_difference,n_components,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)))]);

ax5 = subplot(2,4,5);
surf(latency_difference,n_components,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)))]);

ax6 = subplot(2,4,6);
surf(latency_difference,n_components,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)))]);

ax7 = subplot(2,4,7);
surf(latency_difference,n_components,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

% make plot larger
set(gcf, 'Position', get(0, 'Screensize'));
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);

sgtitle('MSE for Different Metrics and Latency Differences and Number of Components');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp.png');


dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,1),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,1),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,1),4));
baseline_mse_p1 = squeeze(mean(mean(baseline_mse,1),4));
frac_peak_mse_p1 = squeeze(mean(mean(frac_peak_mse,1),4));
peak_lat_mse_p1 = squeeze(mean(mean(peak_lat_mse,1),4));
peak_area_mse_p1 = squeeze(mean(mean(peak_area_mse,1),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:); baseline_mse_p1(:); frac_peak_mse_p1(:); peak_lat_mse_p1(:); peak_area_mse_p1(:)]);


figure();
ax1 = subplot(2,4,1);
surf(latency_difference,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(2,4,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(2,4,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);


ax4 = subplot(2,4,4);
surf(latency_difference,sig_length,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)))]);

ax5 = subplot(2,4,5);
surf(latency_difference,sig_length,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)))]);

ax6 = subplot(2,4,6);
surf(latency_difference,sig_length,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)))]);

ax7 = subplot(2,4,7);
surf(latency_difference,sig_length,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

% make plot larger
set(gcf, 'Position', get(0, 'Screensize'));
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);

sgtitle('MSE for Different Metrics and Latency Differences and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen.png');

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,3),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,3),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,3),4));
baseline_mse_p1 = squeeze(mean(mean(baseline_mse,3),4));
frac_peak_mse_p1 = squeeze(mean(mean(frac_peak_mse,3),4));
peak_lat_mse_p1 = squeeze(mean(mean(peak_lat_mse,3),4));
peak_area_mse_p1 = squeeze(mean(mean(peak_area_mse,3),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:); baseline_mse_p1(:); frac_peak_mse_p1(:); peak_lat_mse_p1(:); peak_area_mse_p1(:)]);


figure();
ax1 = subplot(2,4,1);
surf(sig_length,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
ylabel('Latency Difference');
xlabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(2,4,2);
surf(sig_length,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(2,4,3);
surf(sig_length,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);


ax4 = subplot(2,4,4);
surf(sig_length,n_components,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)))]);

ax5 = subplot(2,4,5);
surf(sig_length,n_components,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)))]);

ax6 = subplot(2,4,6);
surf(sig_length,n_components,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)))]);

ax7 = subplot(2,4,7);
surf(sig_length,n_components,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
xlabel('Length of Signal');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

% make plot larger
set(gcf, 'Position', get(0, 'Screensize'));
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);

sgtitle('MSE for Different Metrics and Latency Differences and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen.png');