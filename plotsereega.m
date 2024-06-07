% load data
load('Results\data\dtw_mse_median.mat')
load('Results\data\dtw_mse_weighted_median.mat')
load('Results\data\dtw_mse_95.mat')
load('Results\data\baseline_mse.mat')
load('Results\data\frac_peak_mse.mat')
load('Results\data\peak_lat_mse.mat')
load('Results\data\peak_area_mse.mat')
load('Results\data\expParams.mat')


latency_difference = expParams.latency_difference;
n_components = expParams.components; 
sig_length = expParams.sig_length; % time in S
% first dim is N-comonents
% second dim is length of signal
% third dim is latency difference
% fourth dim is num_permutations
% values are MSE for each permutation


formatSpec = '%.4f';

% plot grid of subplots for each possible 3d slice of the data
% create surf plots with interp shading, first set should contain 
% x should be latency difference, y should be number of components, z should be MSE (averaged)

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,2),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,2),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,2),5)),1));
baseline_mse_p1 = squeeze(mean(squeeze(mean(mean(baseline_mse,2),5)),1));
frac_peak_mse_p1 = squeeze(mean(squeeze(mean(mean(frac_peak_mse,2),5)),1));
peak_lat_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_lat_mse,2),5)),1));
peak_area_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,2),5)),1));

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
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(2,4,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(2,4,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);


ax4 = subplot(2,4,4);
surf(latency_difference,n_components,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)),formatSpec)]);

ax5 = subplot(2,4,5);
surf(latency_difference,n_components,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)),formatSpec)]);

ax6 = subplot(2,4,6);
surf(latency_difference,n_components,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)),formatSpec)]);

ax7 = subplot(2,4,7);
surf(latency_difference,n_components,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)),formatSpec)]);

% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);

ax8 = subplot(2,4,8);
colorbar;
clim([0 maxColor]);
axis off;

% make plot larger
set(gcf, 'Position', [0, 0, 1280, 720]);


sgtitle('MSE for Different Methods, Latency Differences and Number of Components');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,3),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,3),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,3),5)),1));
baseline_mse_p1 = squeeze(mean(squeeze(mean(mean(baseline_mse,3),5)),1));
frac_peak_mse_p1 = squeeze(mean(squeeze(mean(mean(frac_peak_mse,3),5)),1));
peak_lat_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_lat_mse,3),5)),1));
peak_area_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,3),5)),1));

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
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(2,4,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(2,4,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);


ax4 = subplot(2,4,4);
surf(latency_difference,sig_length,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)),formatSpec)]);

ax5 = subplot(2,4,5);
surf(latency_difference,sig_length,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)),formatSpec)]);

ax6 = subplot(2,4,6);
surf(latency_difference,sig_length,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)),formatSpec)]);

ax7 = subplot(2,4,7);
surf(latency_difference,sig_length,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)),formatSpec)]);



% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);

ax8 = subplot(2,4,8);
colorbar;
clim([0 maxColor]);
axis off;

% make plot larger
set(gcf, 'Position', [0, 0, 1280, 720]);

sgtitle('MSE for Different Methods, Latency Differences and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,5),4)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,5),4)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,5),4)),1));
baseline_mse_p1 = squeeze(mean(squeeze(mean(mean(baseline_mse,5),4)),1));
frac_peak_mse_p1 = squeeze(mean(squeeze(mean(mean(frac_peak_mse,5),4)),1));
peak_lat_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_lat_mse,5),4)),1));
peak_area_mse_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,5),4)),1));

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
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax2 = subplot(2,4,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax3 = subplot(2,4,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);


ax4 = subplot(2,4,4);
surf(n_components,sig_length,baseline_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Baseline Deviation');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(baseline_mse_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax5 = subplot(2,4,5);
surf(n_components,sig_length,frac_peak_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Peak');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(frac_peak_mse_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax6 = subplot(2,4,6);
surf(n_components,sig_length,peak_lat_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Peak Latency');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_lat_mse_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax7 = subplot(2,4,7);
surf(n_components,sig_length,peak_area_mse_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse_p1(:)),formatSpec)]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

ax8 = subplot(2,4,8);
colorbar;
clim([0 maxColor]);
axis off;


% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7],'xy');

% make plot larger
set(gcf, 'Position', [0, 0, 1280, 720]);
ylim([min(sig_length) max(sig_length)]);
xlim([min(n_components) max(n_components)]);

sgtitle('MSE for Different Methods, Number of Components and Length of Signal');

% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen_comp.png');


% table describing the average MSE for each metric along with standard deviation and range and median
% create table with rows as metrics and columns as average, std, range, median
% average is mean of all values

% create table
metrics = {'DTW Median','DTW Z-Weighted Median','DTW 95th Percentile','Baseline Deviation','Fractional Peak','Peak Latency','Fractional Area'};
average = [mean(dtw_mse_median(:)),mean(dtw_mse_weighted_median(:)),mean(dtw_mse_95(:)),mean(baseline_mse(:)),mean(frac_peak_mse(:)),mean(peak_lat_mse(:)),mean(peak_area_mse(:))];
std_dev = [std(dtw_mse_median(:)),std(dtw_mse_weighted_median(:)),std(dtw_mse_95(:)),std(baseline_mse(:)),std(frac_peak_mse(:)),std(peak_lat_mse(:)),std(peak_area_mse(:))];
ranges = [range(dtw_mse_median(:)),range(dtw_mse_weighted_median(:)),range(dtw_mse_95(:)),range(baseline_mse(:)),range(frac_peak_mse(:)),range(peak_lat_mse(:)),range(peak_area_mse(:))];
medians = [median(dtw_mse_median(:)),median(dtw_mse_weighted_median(:)),median(dtw_mse_95(:)),median(baseline_mse(:)),median(frac_peak_mse(:)),median(peak_lat_mse(:)),median(peak_area_mse(:))];
T = table(average',std_dev',ranges',medians','RowNames',metrics,'VariableNames',{'Average','Standard_Deviation','Range','Median'});
disp(T);

% save table 
writetable(T,'Results\mse_table.csv','WriteRowNames',true);


% repeat all graphs but only for DTW methods on 1x3 subplot

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,2),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,2),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,2),5)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,4,1);
surf(latency_difference,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(1,4,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
linkaxes([ax1,ax2,ax3],'xy');
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);
xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;

% join axes and set x and y lims to be the same

sgtitle('MSE for Different DTW Metrics, Latency Differences and Number of Components');
set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp_dtw.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,3),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,3),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,3),5)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,4,1);
surf(latency_difference,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(1,4,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);

linkaxes([ax1,ax2,ax3],'xy');

xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics, Latency Differences and Length of Signal');

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;

set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen_dtw.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,5),4)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,5),4)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_95,5),4)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);
figure();
ax1 = subplot(1,4,1);
surf(n_components,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(1,4,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW 95th Percentile');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);

linkaxes([ax1,ax2,ax3],'xy');

xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Different DTW Metrics, Number of Components and Length of Signal');

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;

% join axes and set x and y lims to be the same

set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_comp_siglen_dtw.png');


dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,2),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,2),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,2),5)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,4,1);
surf(latency_difference,n_components,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Number of Components');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(latency_difference,n_components,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(1,4,3);
surf(latency_difference,n_components,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(peak_area_mse(:)),formatSpec)]);



% join axes and set x and y lims to be the same
linkaxes([ax1,ax2,ax3],'xy');

xlim([min(latency_difference) max(latency_difference)]);
ylim([min(n_components) max(n_components)]);
sgtitle('MSE for Latency Metrics, Latency Differences and Number of Components');

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;
set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_lat_comp_pa.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,3),5)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,3),5)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,3),5)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);

figure();
ax1 = subplot(1,4,1);
surf(latency_difference,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Latency Difference');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(latency_difference,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);

ax3 = subplot(1,4,3);
surf(latency_difference,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);

linkaxes([ax1,ax2,ax3],'xy');

xlim([min(latency_difference) max(latency_difference)]);
ylim([min(sig_length) max(sig_length)]);
sgtitle('MSE for Latency Metrics, Latency Differences and Length of Signal');

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;

% join axes and set x and y lims to be the same

set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_lat_siglen_pa.png');

dtw_mse_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_median,5),4)),1));
dtw_mse_weighted_median_p1 = squeeze(mean(squeeze(mean(mean(dtw_mse_weighted_median,5),4)),1));
dtw_mse_95_p1 = squeeze(mean(squeeze(mean(mean(peak_area_mse,5),4)),1));

maxColor = max([dtw_mse_median_p1(:); dtw_mse_weighted_median_p1(:); dtw_mse_95_p1(:)]);
figure();
ax1 = subplot(1,4,1);
surf(n_components,sig_length,dtw_mse_median_p1,'EdgeColor','none');
view(2);
shading interp;
xlabel('Number of Components');
ylabel('Length of Signal');
title('DTW Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_median_p1(:)),formatSpec)]);

ax2 = subplot(1,4,2);
surf(n_components,sig_length,dtw_mse_weighted_median_p1,'EdgeColor','none');
view(2);
shading interp;
title('DTW Z-Weighted Median');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_weighted_median_p1(:)),formatSpec)]);
xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);

ax3 = subplot(1,4,3);
surf(n_components,sig_length,dtw_mse_95_p1,'EdgeColor','none');
view(2);
shading interp;
title('Fractional Area');
zlabel('MSE');
clim([0 maxColor]);
subtitle(['Average MSE: ' num2str(mean(dtw_mse_95_p1(:)),formatSpec)]);
xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);

linkaxes([ax1,ax2,ax3],'xy');

xlim([min(n_components) max(n_components)]);
ylim([min(sig_length) max(sig_length)]);

sgtitle('MSE for Latency Metrics, Number of Components and Length of Signal');

ax4 = subplot(1,4,4);
colorbar;
clim([0 maxColor]);
axis off;



% join axes and set x and y lims to be the same

set(gcf, 'Position', [0, 0, 1280, 720]);
% save plot
saveas(gcf,'Results\mse_3d_slices_comp_siglen_pa.png');

%% now plotting curves for increasing SNRM, snr is x axis and mse is y axis, average all other dimensions, mean dimensions 5,4,3,2 and squeeze
dtw_median_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(dtw_mse_median,5)),4)),3)),2)))');
dtw_weighted_median_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(dtw_mse_weighted_median,5)),4)),3)),2)))');
dtw_95_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(dtw_mse_95,5)),4)),3)),2)))');
baseline_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(baseline_mse,5)),4)),3)),2)))');
frac_peak_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(frac_peak_mse,5)),4)),3)),2)))');
peak_lat_snr =  fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(peak_lat_mse,5)),4)),3)),2)))');
peak_area_snr = fliplr(squeeze(squeeze(mean(squeeze(mean(squeeze(mean(squeeze(mean(peak_area_mse,5)),4)),3)),2)))');

snr = fliplr(expParams.SNRs);
snr = 1./snr;

figure;
semilogx(snr,dtw_median_snr,"LineWidth",2);
hold on;
semilogx(snr,dtw_weighted_median_snr,"LineWidth",2);
semilogx(snr,dtw_95_snr,"LineWidth",2);
semilogx(snr,baseline_snr,"LineWidth",2);
semilogx(snr,frac_peak_snr,"LineWidth",2);
semilogx(snr,peak_lat_snr,"LineWidth",2);
semilogx(snr,peak_area_snr,"LineWidth",2);
xlim([snr(1), snr(end)])
% add at least 5 xticks
xticks([0.2,0.3,0.4, 0.5,0.75,1,1.5,2,3,5,10])
xlabel('SNRM');
ylabel('MSE');
title('MSE vs SNRM for Different Methods');
legend('DTW Median','DTW Z-Weighted Median','DTW 95th Percentile','Baseline Deviation','Fractional Peak','Peak Latency','Fractional Area','Location','northeastoutside');
set(gca, 'FontSize', 14)
set(gcf, 'Position', [0, 0, 1280, 720]);
saveas(gcf,'Results\mse_snr.png');

figure;
semilogx(snr,dtw_median_snr,"LineWidth",2);
hold on;
semilogx(snr,dtw_weighted_median_snr,"LineWidth",2);
semilogx(snr,dtw_95_snr,"LineWidth",2);
xlim([snr(1), snr(end)])
% add at least 5 xticks
xticks([0.2,0.3,0.4, 0.5,0.75,1,1.5,2,3,5,10])
xlabel('SNRM');
ylabel('MSE');
title('MSE vs SNRM for DTW Methods');
legend('DTW Median','DTW Z-Weighted Median','DTW 95th Percentile','Location','northeastoutside');
set(gca, 'FontSize', 14)
set(gcf, 'Position', [0, 0, 1280, 720]);
saveas(gcf,'Results\mse_snr_DTW.png');

