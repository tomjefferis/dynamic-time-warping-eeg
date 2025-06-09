addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
addpath('W:\PhD\MatlabPlugins\spm12') % path to spm
addpath("C:\Users\Tom\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Patchline")
addpath("funcs\")

grand_avg_filename = 'time_domain_mean_intercept_onsets_2_3_4_5_6_7_8_grand-average.mat';
main_path = 'W:\PhD\PatternGlareData\participants\participant_';
onsets_part = 'onsets';
n_participants = 40;
fs = 512;


[ft_data, order] = load_data(main_path, grand_avg_filename, n_participants, onsets_part);
ft_data_thin_thick = [];
ft_data_med = [];

for i = 1:length(ft_data)
    ft_data{i}.avg = (ft_data{i}.thin + ft_data{i}.thick)/2;
    ft_data_thin_thick{end+1} = ft_data{i};
    ft_data{i}.avg = ft_data{i}.med;
    ft_data_med{end+1} = ft_data{i};
end

cd C:\Users\tomje\Documents\GitHub\dynamic-time-warping-eeg
load("Pattern_Glare_analysis_latencies.mat")

zeroData = warpedLatencies{1};
zeroData.avg = zeros(size(zeroData.avg));

zeroDataFull = cell(1,length(order));
for i = 1:length(order)
    zeroDataFull{i} = zeroData;
end

cfg = [];
cfg.feedback = 'no';
cfg.method = 'distance';
cfg.elec = ft_data{1}.elec;
neighbours = ft_prepare_neighbours(cfg);

cfg = [];
cfg.design = [1:length(order) 1:length(order); ones(1,length(order)) ones(1,length(order))*2];
cfg.ivar = 2;
cfg.uvar = 1;
cfg.latency = [0.056, 0.256];

cfg.computeprob = 'yes';
cfg.alpha = 0.05;
cfg.correcttail = 'alpha';
cfg.clusterthreshold = "nonparametric_common";
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.channel = 'all';
cfg.method = 'montecarlo';
cfg.correctm = 'cluster';
cfg.neighbours = neighbours;
cfg.clusteralpha = 0.025;
cfg.numrandomization = 5000;

stat = ft_timelockstatistics(cfg, warpedLatencies{:}, zeroDataFull{:});

[peak_electrode] = compute_best_electrode(stat, 'negative', 1);

peak_plot = plot_peak_electrode(stat, peak_electrode, "", true)
% save figure
saveas(gcf, "peak_electrode_plot.png")

%% gen ERPS from grand averages at this electrode, plot and dtw matching points
plot_topo_map(stat, 0 , 0.256);
% save figure
saveas(gcf, "topo_map_peak_electrode.png")

peak_elec_index = get_electrode_index(ft_data_med,peak_electrode);


% make square grid subplot (6x6)
figure
for i = 1:length(ft_data_thin_thick)
    subplot(6,6,i)
    thickThinAvg = ft_data_thin_thick{i};
    medAvg = ft_data_med{i};
    % baseline correct the data
    cfg = [];
    cfg.baseline = [-0.2, 0];
    thickThinAvg = ft_timelockbaseline(cfg, thickThinAvg);
    medAvg = ft_timelockbaseline(cfg, medAvg);
    thickThin_series = thickThinAvg.avg(peak_elec_index,:);
    med_series = medAvg.avg(peak_elec_index,:);
    plot(medAvg.time, thickThin_series, "LineWidth", 2)
    hold on
    plot(medAvg.time,med_series,"LineWidth", 2)
    xlim([-0.2, 0.256])
    ylim([-8, 20])
    xline(0.056, "--")
    xline(0.256, "--")
    xline(0)
    % shade where cluster is in time
    cluster_start = peak_electrode.sig_start;
    cluster_end = peak_electrode.sig_end;
    patch([cluster_start, cluster_end, cluster_end, cluster_start], [-20, -20, 20, 20], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    % title(ft_data_thin_thick{i}.subject) + electrode name
    title("Participant " + {i} + " " + ft_data_thin_thick{i}.elec.label{peak_elec_index})
    xlabel("Time (s)")
    ylabel("Amplitude (uV)")
    grid on
end
% set figure size to 1440p
set(gcf, 'Position', [0, 0, 2560, 1440])
% save figure
saveas(gcf, "participants_thin_thick_med.png")


% get grand avg for med and thick/thin
cfg = [];
thickThinAvg = ft_timelockgrandaverage(cfg,ft_data_thin_thick{:});
medAvg = ft_timelockgrandaverage(cfg,ft_data_med{:});
cfg = [];
cfg.baseline = [-0.2, 0];
thickThinAvg = ft_timelockbaseline(cfg, thickThinAvg);
medAvg = ft_timelockbaseline(cfg, medAvg);
% get dtw from these two GAs at the electrode index from peak_electrode
thinthick_series = thickThinAvg.avg(peak_elec_index,:);
med_series = medAvg.avg(peak_elec_index,:);
[c,ix,iy] = dtw(thinthick_series,med_series);
% plot the GA with warping path and matching points on plot
% setting xlim for analysis window [0.056, 0.256]
% line thickness 2

figure
plot(medAvg.time, thinthick_series,'LineWidth',2)
hold on
plot(medAvg.time,med_series,'LineWidth',2)
xlim([-0.2, 0.256])
ylim([-5, 8])
xline(0.056, "--")
xline(0.256, "--")
xline(0)
% shade where cluster is in time
cluster_start = peak_electrode.sig_start;
cluster_end = peak_electrode.sig_end;
patch([cluster_start, cluster_end, cluster_end, cluster_start], [-10, -10, 10, 10], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
xlabel("Time (s)")
ylabel("Amplitude (uV)")
grid on
tit = "Grand Average at " + ft_data_thin_thick{1}.elec.label{peak_elec_index} + " electrode";
title(tit)
peak_effect_time = peak_electrode.time;
xline(peak_effect_time, "--r","LineWidth", 2, "DisplayName", "Max Effect")
legend(["Thick","Medium","","","","Significant Effect","Max Effect"])


% save figure
saveas(gcf, "grand_average_thin_thick_med.png")

% start index is the 0.056, end index is 0.256, get index from medAvg.time and crop the med_series and thinthick_series
start_idx = find(medAvg.time >= 0.056, 1, 'first');
end_idx = find(medAvg.time <= 0.256, 1, 'last');
max_effect = find(medAvg.time <= peak_electrode.time, 1, 'last') - start_idx;
med_series = med_series(start_idx:end_idx);
thinthick_series = thinthick_series(start_idx:end_idx);

med_series = zscore(med_series);
thinthick_series = zscore(thinthick_series);


[dist, ix, iy] = dtw(med_series,thinthick_series)

peak_effect_idx = max_effect;
% Get lengths for axis matching
n_ref = length(med_series);
n_query = length(thinthick_series);
cmap = colororder();

figure;

% TOP LEFT — med_series vertically aligned (flipped so index 0 is at top)
subplot(3,3,[1 4]);
plot(med_series, 0:n_ref-1,'LineWidth',2, 'Color', cmap(2,:)); % plot horizontally
set(gca, 'XDir', 'reverse'); % So 0 is top
ylim([0, n_ref-1]);
xlabel('Amplitude Z-Score');
ylabel('Reference index');
grid on;
yline(peak_effect_idx, "--r","LineWidth", 2, "DisplayName", "Max Effect")

% CENTER — warping path
subplot(3,3,[2 3 5 6]);
plot(ix, iy, 'LineWidth', 2);
xlabel('Query index');
ylabel('Reference index');
title('DTW Warping Path');
% Add diagonal reference line x = y
hold on;
lims = [0, min(n_query-1, n_ref-1)];
plot(lims, lims, '--', 'Color', [0.5 0.5 0.5],'LineWidth',2); % dashed grey line
xlim([0, n_query-1]);
ylim([0, n_ref-1]);
grid on;
% max effect marker - dot at the peak effect time 

plot(peak_effect_idx, peak_effect_idx, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Max Effect');

% BOTTOM RIGHT — thinthick_series horizontally
subplot(3,3,[8 9]);
plot(0:n_query-1, thinthick_series,'LineWidth',2);
xlabel('Query index');
ylabel('Amplitude Z-Score');
xlim([0, n_query-1]);
grid on;
hold on;
xline(peak_effect_idx, "--r","LineWidth", 2, "DisplayName", "Max Effect")

% title the figure
sgtitle("DTW Matching: " + ft_data_thin_thick{1}.elec.label{peak_elec_index} + " electrode");
% save figure
saveas(gcf, "dtw_matching_thin_thick_med.png")