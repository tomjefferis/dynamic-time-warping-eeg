%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath funcs\

%% Script config
% script parameters
n_signals_generate = 1000;
% Component parameters
latency_difference = -0.1:0.01:0.1;
SNRs = [0, 0.1, 0.25, 0.5, 0.6, 0.7, 0.8, 0.9,1,1.5,2,3,4,5,6,7,8,10]; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs

% params not to change unless different signal wanted
fs = 1000; % sample rate
sig_length = 1; % time in S
window_widths = sig_length/25:sig_length/25:sig_length-350/fs;



% result arrays
dtw_mse_median = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
dtw_mse_weighted_median = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
dtw_mse_95 = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
baseline_mse = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
frac_peak_mse = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
peak_lat_mse = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);
peak_area_mse = NaN(length(SNRs), length(latency_difference),length(window_widths), n_signals_generate);

parfor i = 1:length(SNRs)
    SNR = SNRs(i);
    
    % temp arrays
    temp_dtw_mse_median = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_dtw_mse_weighted_median = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_dtw_mse_95 = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_baseline_mse = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_frac_peak_mse = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_peak_lat_mse = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    temp_peak_area_mse = NaN( length(latency_difference),length(window_widths), n_signals_generate);
    
    for j = 1:length(latency_difference)
        latency_diff = latency_difference(j);
        for k = 1:length(window_widths)
            
            window_width = window_widths(k)*fs;
            
            
            for n = 1:n_signals_generate

                erp = struct();
                erp.peakAmplitude = [3,-6,3,-2,7];
                erp.peakLatency = [200,270,320,360,650];
                erp.peakWidth = [65,70,56,55,600];
                erp.probability = 1;
                erp.type = 'erp';
                erp.probabilitySlope = 0;
                erp = utl_check_class(erp);
                
                epochs = struct();
                epochs.n = 1;             % the number of epochs to simulate
                epochs.srate = fs;        % their sampling rate in Hz
                epochs.length = sig_length*fs;       % their length in ms
                
                noise = struct( ...
                    'type', 'noise', ...
                    'color', 'pink', ...
                    'amplitude', max(abs(erp.peakAmplitude))*SNR);
                noise = utl_check_class(noise);
                
                sig1 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);
                
                erp.peakLatency(5) = erp.peakLatency(5) + latency_diff*fs;
                
                sig2 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);
                
                N = 2; 
                [B,A] = butter(N,[1 35]/(fs/2));
                data = struct();
                data.erp = filter(B,A,sig1)';
                data2 = struct();
                data2.erp = filter(B,A,sig2)';

                % baseline correct from [1:100]
                b1 = data.erp(1:100);
                b1 = mean(b1);
                b2 = data2.erp(1:100);
                b2 = mean(b2);
                data.erp = data.erp - b1;
                data2.erp = data2.erp - b2;

                %% Implemented P1N1P3 ERP shape and move the P3 component, start window at 350ms 
                window_start = 350;
                window_end = window_start + round(window_width);

                if window_end > length(data.erp)
                    window_end = length(data.erp);
                end
                
                sig1_window = struct();
                sig2_window = struct();
                sig1_window.erp = data.erp(window_start:window_end);
                sig2_window.erp = data2.erp(window_start:window_end);
                
                baselines = struct();
                baselines.one = data.erp(1:100);
                baselines.two = data2.erp(1:100);

                % needa  way to add baseline in, maybe just append to
                % front for these methods?
                [dtw_median, dtw_weighted_median, dtw_95] = dynamictimewarper(sig2_window, sig1_window, fs);
                peakLat = peaklatency(sig2_window,sig1_window,fs);
                fracPeakLat = fracpeaklatency(sig2_window,sig1_window,fs);
                areaLat = peakArea(sig2_window,sig1_window,fs, 0.5, baselines);
                baselineLat = baselineDeviation(sig2_window,sig1_window,fs, baselines,2);

                temp_dtw_mse_median(j,k,n) = mean((dtw_median - latency_diff).^2);
                temp_dtw_mse_weighted_median(j,k,n) = mean((dtw_weighted_median - latency_diff).^2);
                temp_dtw_mse_95(j,k,n) = mean((dtw_95 - latency_diff).^2);
                temp_baseline_mse(j,k,n) = mean((baselineLat - latency_diff).^2);
                temp_frac_peak_mse(j,k,n) = mean((fracPeakLat - latency_diff).^2);
                temp_peak_lat_mse(j,k,n) = mean((peakLat - latency_diff).^2);
                temp_peak_area_mse(j,k,n) = mean((areaLat - latency_diff).^2);
                                       
            end
        end
    end
    dtw_mse_median(i,:,:,:) = temp_dtw_mse_median;
    dtw_mse_weighted_median(i,:,:,:) = temp_dtw_mse_weighted_median;
    dtw_mse_95(i,:,:,:) = temp_dtw_mse_95;
    baseline_mse(i,:,:,:) = temp_baseline_mse;
    frac_peak_mse(i,:,:,:) = temp_frac_peak_mse;
    peak_lat_mse(i,:,:,:) = temp_peak_lat_mse;
    peak_area_mse(i,:,:,:) = temp_peak_area_mse;
end

% save results
save('Results\ChangingWindow\dtw_mse_median.mat', 'dtw_mse_median')
save('Results\ChangingWindow\dtw_mse_weighted_median.mat', 'dtw_mse_weighted_median')
save('Results\ChangingWindow\dtw_mse_95.mat', 'dtw_mse_95')
save('Results\ChangingWindow\baseline_mse.mat', 'baseline_mse')
save('Results\ChangingWindow\frac_peak_mse.mat', 'frac_peak_mse')
save('Results\ChangingWindow\peak_lat_mse.mat', 'peak_lat_mse')
save('Results\ChangingWindow\peak_area_mse.mat', 'peak_area_mse')
% save params for reference
params = struct();
params.n_signals_generate = n_signals_generate;
params.latency_difference = latency_difference;
params.SNRs = SNRs;
params.fs = fs;
params.sig_length = sig_length;
params.window_widths = window_widths;

save('Results\ChangingWindow\params.mat', 'params')



