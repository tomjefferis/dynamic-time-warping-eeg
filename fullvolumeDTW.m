%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath funcs\
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip

n_participants = 20;
length = 1;
fs = 1000;
offset = 0.1; %100ms

[data1,data2] = fullVolumeData(n_participants,length,fs,offset);

