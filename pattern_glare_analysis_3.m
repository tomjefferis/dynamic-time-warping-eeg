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

windowSizes = round([length(ft_data{i}.time)/10,length(ft_data{i}.time)/5]);

cd C:\Users\Tom\Documents\GitHub\dynamic-time-warping-eeg
load("Pattern_Glare_analysis_latencies.mat")

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

stat = ft_timelockstatistics(cfg, ft_data{:}, zeroDataFull{:});
% save stat
%save("Pattern_Glare_analysis_stat.m","stat","-v7.3")
% save warped_latencies
% Calculate time points for the full signal
full_time = ft_data{1}.time;
stat_time = stat.time;
% Find indices of time points to start and end of stat time
mask_start_idx = find(full_time == stat_time(1));
mask_end_idx = find(full_time == stat_time(end));

% Create mask array matching full time series length
mask = zeros(size(ft_data{1}.avg));
% Insert the cluster labels for the time period of interest
mask(:,mask_start_idx:mask_end_idx) = stat.posclusterslabelmat;

% Apply mask to data - set everything to NaN except where mask == 1
for i = 1:length(warpedLatencies)
    masked_data = warpedLatencies{i}.avg;
    masked_data(mask ~= 1) = NaN;
    warpedLatencies{i}.avg = masked_data;
end

% Do the same for zero data
for i = 1:length(zeroDataFull)
    masked_data = zeroDataFull{i}.avg;
    masked_data(mask ~= 1) = NaN;
    zeroDataFull{i}.masked_avg = masked_data;
end


% run stats again inside this roi with warped latency and zero data

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
save("Pattern_Glare_analysis_stat_roi.m","stat","-v7.3")
