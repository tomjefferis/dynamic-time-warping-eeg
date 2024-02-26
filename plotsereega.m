% load data
load('Results\data\dtw_mse_median.mat')
load('Results\data\dtw_mse_weighted_median.mat')
load('Results\data\dtw_mse_95.mat')
load('Results\data\baseline_mse.mat')
load('Results\data\frac_peak_mse.mat')
load('Results\data\peak_lat_mse.mat')
load('Results\data\peak_area_mse.mat')
% change name of data to _1
dtw_mse_median_1 = dtw_mse_median;
dtw_mse_weighted_median_1 = dtw_mse_weighted_median;
dtw_mse_95_1 = dtw_mse_95;
baseline_mse_1 = baseline_mse;
frac_peak_mse_1 = frac_peak_mse;
peak_lat_mse_1 = peak_lat_mse;
peak_area_mse_1 = peak_area_mse;

% load data with _1 at the end
load('Results\data\dtw_mse_median_1.mat')
load('Results\data\dtw_mse_weighted_median_1.mat')
load('Results\data\dtw_mse_95_1.mat')
load('Results\data\baseline_mse_1.mat')
load('Results\data\frac_peak_mse_1.mat')
load('Results\data\peak_lat_mse_1.mat')
load('Results\data\peak_area_mse_1.mat')

% combine data from both sets joining on the last dimension of the 4d array
dtw_mse_median = cat(4,dtw_mse_median,dtw_mse_median_1);
dtw_mse_weighted_median = cat(4,dtw_mse_weighted_median,dtw_mse_weighted_median_1);
dtw_mse_95 = cat(4,dtw_mse_95,dtw_mse_95_1);
baseline_mse = cat(4,baseline_mse,baseline_mse_1);
frac_peak_mse = cat(4,frac_peak_mse,frac_peak_mse_1);
peak_lat_mse = cat(4,peak_lat_mse,peak_lat_mse_1);
peak_area_mse = cat(4,peak_area_mse,peak_area_mse_1);

latency_difference = -0.1:0.02:0.1;
n_components = 1:8; 
sig_length = [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.25 1.5 1.75 2 2.5 3]; % time in S
% first dim is N-comonents
% second dim is length of signal
% third dim is latency difference
% fourth dim is num_permutations
% values are MSE for each permutation




% plot grid of subplots for each possible 3d slice of the data
% create surf plots with interp shading, first set should contain 
% x should be latency difference, y should be number of components, z should be MSE (averaged)

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
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);

sgtitle('MSE for Different Methods, Latency Differences and Number of Components');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp.png');


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
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);

sgtitle('MSE for Different Methods, Latency Differences and Length of Signal');

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
surf(n_components,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(2,4,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(2,4,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);


ax4 = subplot(2,4,4);
surf(n_components,sig_length,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)))]);

ax5 = subplot(2,4,5);
surf(n_components,sig_length,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)))]);

ax6 = subplot(2,4,6);
surf(n_components,sig_length,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)))]);

ax7 = subplot(2,4,7);
surf(n_components,sig_length,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

% make plot larger
set(gcf, 'Position', [0, 0, 1280, 720]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

sgtitle('MSE for Different Methods, Number of Components and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen.png');


% table describing the average MSE for each metric along with standard deviation and range and median
% create table with rows as metrics and columns as average, std, range, median
% average is mean of all values

% create table
metrics = {'DTW Median','DTW Weighted Median','DTW 95th Percentile','Baseline Deviation','Fractional Peak','Peak Latency','Peak Area'};
average = [mean(dtw_mse_median(:)),mean(dtw_mse_weighted_median(:)),mean(dtw_mse_95(:)),mean(baseline_mse(:)),mean(frac_peak_mse(:)),mean(peak_lat_mse(:)),mean(peak_area_mse(:))];
std_dev = [std(dtw_mse_median(:)),std(dtw_mse_weighted_median(:)),std(dtw_mse_95(:)),std(baseline_mse(:)),std(frac_peak_mse(:)),std(peak_lat_mse(:)),std(peak_area_mse(:))];
ranges = [range(dtw_mse_median(:)),range(dtw_mse_weighted_median(:)),range(dtw_mse_95(:)),range(baseline_mse(:)),range(frac_peak_mse(:)),range(peak_lat_mse(:)),range(peak_area_mse(:))];
medians = [median(dtw_mse_median(:)),median(dtw_mse_weighted_median(:)),median(dtw_mse_95(:)),median(baseline_mse(:)),median(frac_peak_mse(:)),median(peak_lat_mse(:)),median(peak_area_mse(:))];
T = table(average',std_dev',ranges',medians','RowNames',metrics,'VariableNames',{'Average','Standard_Deviation','Range','Median'});
disp(T);

% save table 
writetable(T,'Results\mse_table.csv','WriteRowNames',true);


% repeat all graphs but only for DTW methods on 1x3 subplot

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,1),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,1),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,1),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,3,1);
surf(latency_difference,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);
sgtitle('MSE for Different DTW Metrics and Latency Differences and Number of Components');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp_dtw.png');

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,2),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,2),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,2),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,3,1);
surf(latency_difference,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics and Latency Differences and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen_dtw.png');

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,3),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,3),4));
dtw_mse_95_p1 = squeeze(mean(mean(dtw_mse_95,3),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);
figure();
ax1 = subplot(1,3,1);
surf(n_components,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics and Number of Components and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_comp_siglen_dtw.png');


dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,1),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,1),4));
dtw_mse_95_p1 = squeeze(mean(mean(peak_area_mse,1),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,3,1);
surf(latency_difference,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);
sgtitle('MSE for Different DTW Metrics and Latency Differences and Number of Components');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp_pa.png');

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,2),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,2),4));
dtw_mse_95_p1 = squeeze(mean(mean(peak_area_mse,2),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,3,1);
surf(latency_difference,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics and Latency Differences and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen_pa.png');

dtw_mse_median_p1 = squeeze(mean(mean(dtw_mse_median,3),4));
dtw_mse_weighted_median_p1 = squeeze(mean(mean(dtw_mse_weighted_median,3),4));
dtw_mse_95_p1 = squeeze(mean(mean(peak_area_mse,3),4));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);
figure();
ax1 = subplot(1,3,1);
surf(n_components,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)))]);

ax2 = subplot(1,3,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)))]);

ax3 = subplot(1,3,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('Peak Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)))]);
colorbar;

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');
set(gcf, 'Position', [0, 0, 1280, 720]);
xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics and Number of Components and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_comp_siglen_pa.png');