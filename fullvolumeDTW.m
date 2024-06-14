%% adding paths
addpath(genpath('SEREEGA\'))
addpath funcs\
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip

n_participants = 18*2;
length = 1;
fs = 1000;
offset = 0.07; %50ms
baseline = 100; %first 100ms

[data1,data2] = fullVolumeData(n_participants,length,fs,offset);


warpedLatencies = fullVolumeWarper(data1, data2, fs);

zeroData = warpedLatencies{1};
zeroData.avg = zeros(size(zeroData.avg));

zeroDataFull = cell(1,n_participants);
for i = 1:n_participants
    zeroDataFull{i} = zeroData;
end


cfg = [];
cfg.baseline = [-0.1 0];
for i = 1:numel(warpedLatencies)
    warpedLatencies{i} = ft_timelockbaseline(cfg, warpedLatencies{i});
end
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail = 0;
cfg.clustertail = 0;
cfg.alpha = 0.025;
cfg.numrandomization = 1000;
cfg_neighbours = [];
cfg_neighbours.method = 'distance';
cfg_neighbours.layout = 'eeg1010.lay';
cfg.neighbours = ft_prepare_neighbours(cfg_neighbours, data1{1});
cfg.design = [1:n_participants 1:n_participants; ones(1,n_participants) ones(1,n_participants)*2];
cfg.ivar = 2;
cfg.uvar = 1;

stat = ft_timelockstatistics(cfg, warpedLatencies{:}, zeroDataFull{:});

cfg = [];
x = ft_timelockgrandaverage(cfg,data1{:});
y = ft_timelockgrandaverage(cfg,data2{:});
figure;
plot(stat.time,x.avg(1,:),'LineWidth',2);
hold on;
plot(stat.time,y.avg(1,:),'LineWidth',2);

figure;
surf(stat.time, 1:64, stat.stat);
shading interp;
view(2);
colorbar;
title('Stat');
xlim([-0.1 0.9]);
ylim([1 64]);

figure;
surf(stat.time, 1:64, stat.posclusterslabelmat);
shading interp;
view(2);
colorbar;
title('Clusters');
xlim([-0.1 0.9]);
ylim([1 64]);
colormap('lines')

plot_topo_map(stat, -0.1 , 1);

figure;
surf(stat.time, 1:64, x.avg);
shading interp;
view(2);
colorbar;
title('Data');
xlim([-0.1 0.9]);
ylim([1 64]);


print('hello brev')