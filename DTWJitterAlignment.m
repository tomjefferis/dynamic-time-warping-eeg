%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
n_components = 3; % how many components to generate in a signal
component_widths = 25:350; % width of the components, one value per component
component_amplitude = [-3,3]; % amplitude of the components, one value per component
trials_per_ERP = 50; % how many trials to generate per ERP
jitter_amount = 0.1; % how much jitter to add to the components in seconds
n_signals_generate = 5000; % how many ERP signals to generate
sig_len = 0.5; % signal length in seconds
fs = 1000; % sample rate
snr = 10; % signal to noise ratio


[trials,baseSignal,grandAvg,jitters] = DTWJitterLow(jitter_amount,sig_len,fs,trials_per_ERP,component_amplitude,component_widths,snr,n_components);

filteredGA = ft_preproc_bandpassfilter(grandAvg,fs,[1 30])';


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
for i = 1:size(trials, 1)
    [~, dtw_weighted_median, ~] = dynamictimewarper(trials(i,:), baseDTW, fs);    

    % amount to shift the trial by left or right
    offset = round(dtw_weighted_median * fs);
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


    plot(warped_trials(i, :));
end

filtered_warped = ft_preproc_bandpassfilter(mean(warped_trials, 1),fs,[1 60]);
unfiltered_warped = mean(warped_trials, 1);

figure;
hold on;
plot(baseSignal, 'LineWidth', 2);
plot(filteredGA, 'LineWidth', 2);
plot(unfiltered_warped, 'LineWidth', 2);
plot(filtered_warped, 'LineWidth', 2);
legend('Base signal', 'Filtered grand average', 'Mean of warped trials');
title('Base signal, filtered grand average and mean of warped trials');



