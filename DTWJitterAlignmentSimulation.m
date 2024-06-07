%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
n_components = 4; % how many components to generate in a signal
component_widths = 25:350; % width of the components, one value per component
component_amplitude = [-3,3]; % amplitude of the components, one value per component
trials_per_ERP = 50; % how many trials to generate per ERP
jitter_amount = 0.1; % how much jitter to add to the components in seconds
n_signals_generate = 5000; % how many ERP signals to generate
sig_len = 0.5; % signal length in seconds
fs = 1000; % sample rate
snr = 5; % signal to noise ratio


[trials,baseSignal,grandAvg,jitters] = DTWJitterLow(jitter_amount,sig_len,fs,trials_per_ERP,component_amplitude,component_widths,snr,n_components);

filteredGA = ft_preproc_bandpassfilter(grandAvg,fs,[1 30])';


minSum = 100000000000; % set to a large number
currentMinSum = minSum-1;



% array for covariance matrix of the trials 
cov_matrix = zeros(size(trials, 1), size(trials, 1));

for i = 1:size(trials, 1)
    for j = 1:size(trials, 1)
        [cov_matrix(i, j),~,~] = dtw(trials(i, :), trials(j, :));
    end
end

sum_cov = sum(cov_matrix, 2);
% find the trial with the smallest sum of covariances
[~, min_idx] = min(sum_cov);

% base signal is the trial with the smallest sum of covariances, warp trials to this signal using DTW 
baseDTW = trials(min_idx, :);
warped_trials = zeros(size(trials));
% warp all trials to the base signal using DTW
figure;
plot(baseDTW);
hold on;
latencies = [];
for i = 1:size(trials, 1)
    [~, dtw_weighted_median, ~] = dynamictimewarper(trials(i,:), baseDTW, fs);    

    % amount to shift the trial by left or right
    offset = round(dtw_weighted_median * fs);
    latencies(end+1) = offset;
    % shift the trial by the offset by reflecting the signal
    if offset > 0
        try
            warped_trials(i, :) = [trials(i, offset+1:end), fliplr(trials(i, end-offset+1:end))];
        catch
            disp('Error');
        end
    elseif offset < 0
        try
            warped_trials(i, :) = [fliplr(trials(i, 1:abs(offset))), trials(i, 1:end+offset)];
        catch
            disp('Error');
        end
    else
        warped_trials(i, :) = trials(i, :);
    end

end

