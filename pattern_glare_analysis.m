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
    %ft_data{i}.avg = (ft_data{i}.thin + ft_data{i}.thick)/2;
    ft_data{i}.avg = ft_data{i}.thick;
    ft_data_thin_thick{end+1} = ft_data{i};
    ft_data{i}.avg = ft_data{i}.med;
    ft_data_med{end+1} = ft_data{i};
end

cfg = [];
cfg.baseline = [-0.2 0];
for i = 1:numel(ft_data)
    ft_data_med{i} = ft_timelockbaseline(cfg, ft_data_med{i});
    ft_data_thin_thick{i} = ft_timelockbaseline(cfg, ft_data_thin_thick{i});
end

[warpedLatencies, max_index] = fullVolumeWarperFieldTrip(ft_data_med, ft_data_thin_thick, [0.056 0.256]);

zeroData = warpedLatencies{1};
zeroData.avg = zeros(size(zeroData.avg));

zeroDataFull = cell(1,length(order));
for i = 1:length(order)
    zeroDataFull{i} = zeroData;
end

cfg = [];
cfg.baseline = [-0.2 0];
for i = 1:numel(warpedLatencies)
    warpedLatencies{i} = ft_timelockbaseline(cfg, warpedLatencies{i});
end
cd C:\Users\tomje\Documents\GitHub\dynamic-time-warping-eeg
save("Pattern_Glare_analysis_latencies.mat","warpedLatencies","-v7.3")
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
% save stat
save("Pattern_Glare_analysis_stat_main.mat","stat","-v7.3")

[peak_electrode] = compute_best_electrode(stat, 'negative', 2);

peak_elec_index = get_electrode_index(ft_data_med,peak_electrode);

peak_plot = plot_peak_electrode(stat, peak_electrode, "", true)

% make square grid subplot (6x6)
figure
for i = 1:length(ft_data_thin_thick)
    subplot(6,6,i)
    thickThinAvg = ft_data_thin_thick{i};
    medAvg = ft_data_med{i};
    thickThin_series = thickThinAvg.avg(peak_elec_index,:);
    med_series = medAvg.avg(peak_elec_index,:);
    % zscore the data
    thickThin_series = zscore(thickThin_series);
    med_series = zscore(med_series);
    p1 = plot(medAvg.time, thickThin_series, "LineWidth", 2);
    hold on
    p2 = plot(medAvg.time,med_series,"LineWidth", 2);
    xlim([-0.2, 0.256])
    ylim([-6, 6])
    xline(0.056, "--")
    xline(0.256, "--")
    xline(0)
    % shade where cluster is in time
    cluster_start = peak_electrode.sig_start;
    cluster_end = peak_electrode.sig_end;
    patch([cluster_start, cluster_end, cluster_end, cluster_start], [-10, -10, 10, 10], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    title("Participant " + string(i) + " " + string(max_index(i)) + "ms")


end
subplot(6,6,length(ft_data_thin_thick)+1)
hold on
legend([p1, p2], {'Thick', 'Medium'})
% turn off axes for this subplot to only show legend
set(gca, 'Visible', 'off')
% set legend position to be in the bottom right of the plot
set(gca, 'Position', [0.8, 0.1, 0.1, 0.1])


% set figure size to 1440p
sgtitle("Timeseries plot for " + string(peak_electrode.electrode))
set(gcf, 'Position', [0, 0, 2560, 1440])



cfg = [];
wp = ft_timelockgrandaverage(cfg,warpedLatencies{:});
x = ft_timelockgrandaverage(cfg,data1{:});
y = ft_timelockgrandaverage(cfg,data2{:});
figure;
plot(x.time,x.avg(63,:),'LineWidth',2);
hold on;
plot(x.time,y.avg(63,:),'LineWidth',2);
xlabel('Time (s)');
ylabel('Voltage (uV)');

figure;
surf(stat.time, 1:64, stat.stat);
shading interp;
view(2);
colorbar;
title('Stat');
xlim([-0.1 0.9]);
ylim([1 64]);
xlabel('Time (s)');
ylabel('Electrode');

plot_topo_map(stat, -0.2 , 1);

figure;
surf(x.time, 1:64, wp.avg);
shading interp;
view(2);
colorbar;
title('Data');
xlim([-0.1 0.9]);
ylim([1 64]);
xlabel('Time (s)');
ylabel('Electrode');

