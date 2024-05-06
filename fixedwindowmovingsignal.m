%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
% script parameters
n_signals_generate = 5000;
% Component parameters
latency_difference = -0.1:0.01:0.1;
SNRs = 0.0:0.1:5; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs

% params not to change unless different signal wanted
fs = 1000; % sample rate
sig_length = 1; % time in S
window_widths = sig_length/15:sig_length/15:sig_length;



% result arrays
dtw_mse_median = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
dtw_mse_weighted_median = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
dtw_mse_95 = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
baseline_mse = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
frac_peak_mse = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
peak_lat_mse = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);
peak_area_mse = NaN(length(SNRs), length(window_widths), length(latency_difference), n_signals_generate);

for i = 1:length(SNRs)
    SNR = SNRs(i);
    
    % temp arrays
    temp_dtw_mse_median = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_dtw_mse_weighted_median = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_dtw_mse_95 = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_baseline_mse = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_frac_peak_mse = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_peak_lat_mse = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    temp_peak_area_mse = NaN( length(window_widths), length(latency_difference), n_signals_generate);
    
    for j = 1:length(latency_difference)
        latency_diff = latency_difference(j);
        for k = 1:length(window_widths)
            
            window_width = window_widths(k)*fs;
            
            
            for n = 1:length(n_signals_generate)

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
                
                data = struct();
                data.erp = ft_preproc_bandpassfilter(sig1,fs,[1 30])';
                data2 = struct();
                data2.erp = ft_preproc_bandpassfilter(sig2,fs,[1 30])';
                
                %% Implemented P1N1P3 ERP shape and move the P3 component, start window at 350ms 
                window_location = 350;
                for l = 1:length(window_location)
                    window_start = window_location(l);
                    window_end = window_start + window_width;
                    
                    sig1_window = struct();
                    sig2_window = struct();
                    sig1_window.erp = data.erp(window_start:window_end);
                    sig2_window.erp = data2.erp(window_start:window_end);

                    % needa  way to add baseline in, maybe just append to
                    % front for these methods?
                    [dtw_median, dtw_weighted_median, dtw_95] = dynamictimewarper(sig2_window, sig1_window, fs);
                    peakLat = peaklatency(sig2_window,sig1_window,fs);
                    fracPeakLat = fracpeaklatency(sig2_window,sig1_window,fs);
                    areaLat = peakArea(sig2_window,sig1_window,fs, 0.5, baselines);
                    baselineLat = baselineDeviation(sig2_window,sig1_window,fs, baselines,2);

                    temp_dtw_mse_median(j,k,l,n) = mean((dtw_median - latency_diff).^2);
                    temp_dtw_mse_weighted_median(j,k,l,n) = mean((dtw_weighted_median - latency_diff).^2);
                    temp_dtw_mse_95(j,k,l,n) = mean((dtw_95 - latency_diff).^2);
                    temp_baseline_mse(j,k,l,n) = mean((baselineLat - latency_diff).^2);
                    temp_frac_peak_mse(j,k,l,n) = mean((fracPeakLat - latency_diff).^2);
                    temp_peak_lat_mse(j,k,l,n) = mean((peakLat - latency_diff).^2);
                    temp_peak_area_mse(j,k,l,n) = mean((areaLat - latency_diff).^2);
                                       
                    
                end
            end
        end
    end
    dtw_mse_median(i,:,:,:,:) = temp_dtw_mse_median;
    dtw_mse_weighted_median(i,:,:,:,:) = temp_dtw_mse_weighted_median;
    dtw_mse_95(i,:,:,:,:) = temp_dtw_mse_95;
    baseline_mse(i,:,:,:,:) = temp_baseline_mse;
    frac_peak_mse(i,:,:,:,:) = temp_frac_peak_mse;
    peak_lat_mse(i,:,:,:,:) = temp_peak_lat_mse;
    peak_area_mse(i,:,:,:,:) = temp_peak_area_mse;
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
params.n_components = n_components;
params.component_widths = component_widths;
params.component_amplitude = component_amplitude;
params.fs = fs;
params.sig_length = sig_length;
params.intercomponent_jitter = intercomponent_jitter;
params.intercomponent_amp = intercomponent_amp;
params.amplitude_variability = amplitude_variability;
params.window_widths = window_widths;
params.allwinLocs = allwinLocs;

save('Results\ChangingWindow\params.mat', 'params')



