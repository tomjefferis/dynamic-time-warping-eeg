%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
n_components = 4; % how many components to generate in a signal
component_widths = [100,100,100,100]; % width of the components, one value per component
component_amplitude = [1,1,1,1]; % amplitude of the components, one value per component
component_time = [0.1,0.2,0.3,0.4]; % time of the components, one value per component
trials_per_ERP = 200; % how many trials to generate per ERP
n_signals_generate = 10000; % how many ERP signals to generate
sig_len = 1; % signal length in seconds
fs = 1000; % sample rate
snr = 0.3; % signal to noise ratio


