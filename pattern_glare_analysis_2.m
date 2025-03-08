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

cd C:\Users\Tom\Documents\GitHub\dynamic-time-warping-eeg
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

%% gen ERPS from grand averages at this electrode, plot and dtw matching points
plot_topo_map(stat, 0 , 0.3);

peak_elec_index = get_electrode_index(ft_data_med,peak_electrode);


% make square grid subplot (6x6)
figure
for i = 1:length(ft_data_thin_thick)
    subplot(6,6,i)
    thickThinAvg = ft_data_thin_thick{i};
    medAvg = ft_data_med{i};
    thickThin_series = thickThinAvg.avg(peak_elec_index,:);
    med_series = medAvg.avg(peak_elec_index,:);
    plot(medAvg.time, thickThin_series, "LineWidth", 2)
    hold on
    plot(medAvg.time,med_series,"LineWidth", 2)
    xlim([-0.2, 0.256])
    ylim([-6, 6])
    xline(0.056, "--")
    xline(0.256, "--")
    xline(0)
    % shade where cluster is in time
    cluster_start = peak_electrode.sig_start;
    cluster_end = peak_electrode.sig_end;
    patch([cluster_start, cluster_end, cluster_end, cluster_start], [-10, -10, 10, 10], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    
end
% set figure size to 1440p
set(gcf, 'Position', [0, 0, 2560, 1440])


% get grand avg for med and thick/thin
cfg = [];
thickThinAvg = ft_timelockgrandaverage(cfg,ft_data_thin_thick{:});
medAvg = ft_timelockgrandaverage(cfg,ft_data_med{:});
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
ylim([-3, 4])
xline(0.056, "--")
xline(0.256, "--")
xline(0)
% shade where cluster is in time
cluster_start = peak_electrode.sig_start;
cluster_end = peak_electrode.sig_end;
patch([cluster_start, cluster_end, cluster_end, cluster_start], [-10, -10, 10, 10], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none')

[dist, ix, iy] = dtw(med_series,thinthick_series)