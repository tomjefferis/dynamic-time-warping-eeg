%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
n_components = 4; % how many components to generate in a signal
component_widths = 25:250; % width of the components, one value per component
component_amplitude = [-3,3]; % amplitude of the components, one value per component
trials_per_ERP = 200; % how many trials to generate per ERP
jitter_amount = 0.05; % how much jitter to add to the components in seconds
n_signals_generate = 5000; % how many ERP signals to generate
sig_len = 0.4; % signal length in seconds
fs = 1000; % sample rate
snr = 0.7; % signal to noise ratio


% using matlab batch for the loop
%scheduler = parcluster(); % get the current scheduler
%job = createJob(scheduler); % create a job

[trials,baseSignal,grandAvg] = DTWJitterLow(jitter_amount,sig_len,fs,trials_per_ERP,component_amplitude,component_widths,snr,n_components);

figure;
hold on; % This ensures all plots are displayed on the same figure
for i = 1:size(trials, 1)
    plot(trials(i, :),'LineWidth',1.5);
end
hold off;