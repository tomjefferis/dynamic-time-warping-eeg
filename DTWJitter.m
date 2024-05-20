%% adding paths
addpath(genpath('SEREEGA-master\')) 
%addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
n_components = 5; % how many components to generate in a signal
component_widths = 25:250; % width of the components, one value per component
component_amplitude = [-3,3]; % amplitude of the components, one value per component
trials_per_ERP = 100; % how many trials to generate per ERP
jitter_amount = 0.05; % how much jitter to add to the components in seconds
n_signals_generate = 5000; % how many ERP signals to generate
sig_len = 0.5; % signal length in seconds
fs = 1000; % sample rate
snr = 2; % signal to noise ratio


% using matlab batch for the loop
%scheduler = parcluster(); % get the current scheduler
%job = createJob(scheduler); % create a job

[trials,baseSignal,grandAvg,jitters] = DTWJitterLow(jitter_amount,sig_len,fs,trials_per_ERP,component_amplitude,component_widths,snr,n_components);

filteredGA = ft_preproc_bandpassfilter(grandAvg,fs,[1 30])';

% array for storing latency differences between trials and GA, 2 rows, one for each method
lat_differences = zeros(2, size(trials, 1));


% plot trials
figure;
hold on;
for i = 1:size(trials, 1)
    plot(trials(i, :));
end


for i = 1:size(trials, 1)
    tempquesry = [];
    tempquesry.erp = ft_preproc_bandpassfilter(trials(i, :),fs,[1 30])';

    tempreference = [];
    tempreference.erp = filteredGA';

    [dtw_median, dtw_weighted_median, ~] = dynamictimewarper(tempquesry, tempreference, fs);
    lat_differences(1, i) = dtw_median;
    lat_differences(2, i) = dtw_weighted_median;
end
jitters = jitters/fs;
% print average latency differences, range and standard deviation for each method
disp('DTW median:');
disp(strcat('Mean: ', num2str(mean(lat_differences(1, :)))));
disp(strcat('Range: ', num2str(range(lat_differences(1, :)))));
disp(strcat('Standard deviation: ', num2str(std(lat_differences(1, :)))));
disp('DTW weighted median:');
disp(strcat('Mean: ', num2str(mean(lat_differences(2, :)))));
disp(strcat('Range: ', num2str(range(lat_differences(2, :)))));
disp(strcat('Standard deviation: ', num2str(std(lat_differences(2, :)))));
disp(' ');
disp('Actual jitter:');
disp(strcat('Mean: ', num2str(mean(jitters))));
disp(strcat('Range: ', num2str(range(jitters))));
disp(strcat('Standard deviation: ', num2str(std(jitters))));









