%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
% script parameters
n_signals_generate = 500;
% Component parameters
latency_difference = -0.1:0.01:0.1;
SNRs = 0.0:0.1:5; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs

% params not to change unless different signal wanted
n_components = 5;
component_widths = 25:250;
component_amplitude = [-5:5];
fs = 1000; % sample rate
sig_length = 1; % time in S
intercomponent_jitter = 0.07; % jitter between components in S
intercomponent_amp = 0.1; % amplitude difference between components
amplitude_variability = 0.1; % variability of amplitude, not implemented yet
window_widths = sig_length/10:sig_length/10:sig_length;

allwinLocs = [];
for i = 1
    allwinLocs = [allwinLocs, 1:window_widths(i)/2:sig_length*fs-window_widths(i)];
end


% result arrays
dtw_mse_median = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
dtw_mse_weighted_median = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
dtw_mse_95 = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
baseline_mse = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
frac_peak_mse = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
peak_lat_mse = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
peak_area_mse = NaN(length(SNRs), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);

for i = 1:length(SNRs)
    SNR = SNRs(i);
    
    % temp arrays
    temp_dtw_mse_median = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_dtw_mse_weighted_median = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_dtw_mse_95 = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_baseline_mse = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_frac_peak_mse = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_peak_lat_mse = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    temp_peak_area_mse = NaN( length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
    
    for j = 1:length(latency_difference)
        latency_diff = latency_difference(j);
        for k = 1:length(window_widths)
            
            window_width = window_widths(k)*fs;
            
            
            for n = 1:length(n_signals_generate)
                erp = [];
                erp = erp_get_class_random(n_components, round(sig_length*fs*0.15) : round(sig_length*fs*0.75), component_widths, component_amplitude,'numClasses', 1);
                
                % have random deviations selecter from 0 to intercomponent_jitter needing n_components random values
                erp.peakLatencyDv  = randi([0, intercomponent_jitter*fs], 1, n_components);
                erp.peakAmplitudeDv = randi([0, 100], 1, n_components)/200;
                
                epochs = struct();
                epochs.n = 1;             % the number of epochs to simulate
                epochs.srate = fs;        % their sampling rate in Hz
                epochs.length = sig_length*fs;       % their length in ms
                
                noise = struct( ...
                    'type', 'noise', ...
                    'color', 'pink', ...
                    'amplitude', max(component_amplitude)*SNR);
                noise = utl_check_class(noise);
                
                sig1 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);
                
                erp.peakLatency = erp.peakLatency + latency_diff*fs;
                
                sig2 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);
                
                data = struct();
                data.erp = ft_preproc_bandpassfilter(sig1,fs,[1 30])';
                data2 = struct();
                data2.erp = ft_preproc_bandpassfilter(sig2,fs,[1 30])';
                
                
                window_location = 1:window_width/2:sig_length*fs-window_width;
                for l = 1:length(window_location)
                    window_start = window_location(l);
                    window_end = window_start + window_width;
                    
                    sig1_window = struct();
                    sig2_window = struct();
                    sig1_window.erp = data.erp(window_start:window_end);
                    sig2_window.erp = data2.erp(window_start:window_end);


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



