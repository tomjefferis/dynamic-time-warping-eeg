%% EEG pattern glare analysis - Author: Tom Jefferis
%% This file is used for running DTW on the EEG data
%% setting up paths to plugins and default folder
clear all;
restoredefaultpath;
addpath funcs/


SNR = 0.8; % signal to noise ratio
num_permutations = 100; % number of times to generate signal per snr level
signalLens = 0.3:0.05:1; % signal lengths to test in seconds
latencyDiffs = -0.2:0.005:0.2; % latency difference between signals in seconds
fs = 1000; % sampling frequency
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds


iqr_dtw_distances = zeros(num_permutations,length(signalLens), length(latencyDiffs));
max_dtw_distances = zeros(num_permutations, length(signalLens), length(latencyDiffs));
max95_dtw_distances = zeros(num_permutations, length(signalLens), length(latencyDiffs));
peak_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
frac_peak_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
area_latency = zeros(num_permutations, length(signalLens), length(latencyDiffs));
baseline_dev = zeros(num_permutations, length(signalLens), length(latencyDiffs));



for i = 1:length(signalLens)
    signalLen = signalLens(i);
    
    for j = 1:length(latencyDiffs)
        latencyDiff = latencyDiffs(j);
        
        for k = 1:num_permutations

            [sig1s, sig2s] = ERPGenerate(signalLen, fs, variance, SNR, baseline, latencyDiff);

            sig1{1}.erp = sig1s';
            sig2{1}.erp = sig2s';

            baselines = baseline*fs;

            [iqrDist,maxDist,max95Dist] = dynamictimewarper(sig1,sig2,fs);
            peakLat = peaklatency(sig1,sig2,fs);
            fracPeakLat = fracpeaklatency(sig1,sig2,fs);
            areaLat = peakArea(sig1,sig2,fs, 0.5, baselines);
            baselineLat = baselineDeviation(sig1,sig2,fs, baselines,2);


            % Gives the error in the latency difference between method and actual
            iqr_dtw_distances(k,i,j) = iqrDist - latencyDiff;
            max_dtw_distances(k,i,j) = maxDist - latencyDiff;
            max95_dtw_distances(k,i,j) = max95Dist - latencyDiff;
            peak_latency(k,i,j) = peakLat - latencyDiff;
            frac_peak_latency(k,i,j) = fracPeakLat - latencyDiff;
            area_latency(k,i,j) = areaLat - latencyDiff;
            baseline_dev(k,i,j) = baselineLat - latencyDiff;
            
        end
    end

end

% calculate MSE for each method
iqr_dtw_mse = mean(iqr_dtw_distances.^2,1);
max_dtw_mse = mean(max_dtw_distances.^2,1);
max95_dtw_mse = mean(max95_dtw_distances.^2,1);
peak_latency_mse = mean(peak_latency.^2,1);
frac_peak_latency_mse = mean(frac_peak_latency.^2,1);
area_latency_mse = mean(area_latency.^2,1);
baseline_dev_mse = mean(baseline_dev.^2,1);


