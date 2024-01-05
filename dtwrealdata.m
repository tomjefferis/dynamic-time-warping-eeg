clear all
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip

%% Config
noise = 0.2; %Noise to be overlayed on the signal
fs = 250; %Sampling rate of the signal (Should only change if knows fs)
offset = 0.2; %Latency offset of the signals



%% loading data
load('grandavg.mat')

cfg = [];
cfg.baseline = [-0.5 0];
cfg.baselinetype = 'db';
cfg.parameter = 'avg';

grandavg = ft_timelockbaseline(cfg, x);
signal = grandavg.avg(23,:);



