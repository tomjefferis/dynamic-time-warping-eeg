%% adding paths
addpath(genpath('SEREEGA-master\'))
addpath funcs\

%% Script config
% script parameters
n_signals_generate = 5000;
% Component parameters
latency_difference = -0.1:0.05:0.1;
n_components = 1:8;
component_widths = 25:250;
min_amplitude = -10;
max_amplitude = 10;
SNRs = [0, 0.1, 0.25, 0.5, 0.6, 0.7, 0.8, 0.9,1,1.5,2,3,4,5,6,7,8,10]; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs
fs = 1000; % sample rate
sig_length = [0.2,0.4,0.5,0.6,0.7,0.8,1,1.25,1.5,1.75,2,2.5,3]; % time in S
amplitude_variability = 0.1; % variability of amplitude, not implemented yet


% result arrays
dtw_mse_median = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
dtw_mse_weighted_median = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
dtw_mse_95 = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
baseline_mse = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
frac_peak_mse = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
peak_lat_mse = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
peak_area_mse = ones(length(SNRs),length(sig_length), length(n_components), length(latency_difference), n_signals_generate);


parfor t = 1:length(SNRs)
    SNR = SNRs(t);

    temp_dtw_mse_median = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_dtw_mse_weighted_median = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_dtw_mse_95 = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_baseline_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_frac_peak_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_peak_lat_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    temp_peak_area_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
    
    for u = 1:length(sig_length)
        sig_len = sig_length(u);
        
        for i = 1:length(n_components)
            n_component = n_components(i);
            for j = 1:length(latency_difference)
                latency_diff = latency_difference(j);
                
                
                component_range = round(sig_len*fs*0.3) : round(sig_len*fs*0.8);
                
                if sig_len*fs < 500
                    baselines = 10;
                else
                    baselines = round(sig_len*fs*0.1);
                end
                
                amps = [min_amplitude:.1:min_amplitude/2, max_amplitude/2:.1:max_amplitude];
                %erp = erp_get_class_random(n_component, component_range, component_widths, amps);
                erp = erp_get_class_random(n_component, component_range, component_widths, amps,'numClasses', n_signals_generate);
                
                % erp2 with added latency difference
                erp2 = erp;
                for k = 1:n_signals_generate
                    erp2(k).peakLatency = erp2(k).peakLatency + latency_diff*fs;
                end
                
                noise = struct( ...
                    'type', 'noise', ...
                    'color', 'pink', ...
                    'amplitude', max(abs(min_amplitude),abs(max_amplitude))*SNR);
                noise = utl_check_class(noise);
                
                epochs = struct();
                epochs.n = 1;             % the number of epochs to simulate
                epochs.srate = fs;        % their sampling rate in Hz
                epochs.length = sig_len*fs;       % their length in ms
                
                for k = 1:n_signals_generate
                    
                    
                    dat1 = generate_signal_fromclass(erp(k), epochs);
                    noise1 = generate_signal_fromclass(noise, epochs);
                    data1 = dat1 + noise1;
                    
                    
                    dat2 = generate_signal_fromclass(erp2(k), epochs);
                    noise2 = generate_signal_fromclass(noise, epochs);
                    data2_t = dat2 + noise2;
                    
                    N = 2; 
                    [B,A] = butter(N,[1 35]/(fs/2));
                    data = struct();
                    data.erp = filter(B,A,data1)';
                    data2 = struct();
                    data2.erp = filter(B,A,data2_t)';

                    
                    % determine latency difference
                    [dtw_median, dtw_weighted_median, dtw_95] = dynamictimewarper(data2, data, fs);
                    peakLat = peaklatency(data2,data,fs);
                    fracPeakLat = fracpeaklatency(data2,data,fs);
                    areaLat = peakArea(data2,data,fs, 0.5, baselines);
                    baselineLat = baselineDeviation(data2,data,fs, baselines,2);
                    
                    % get mse for each metric
                    temp_dtw_mse_median(u,i,j,k) = mean((dtw_median - latency_diff).^2);
                    temp_dtw_mse_weighted_median(u,i,j,k) = mean((dtw_weighted_median - latency_diff).^2);
                    temp_dtw_mse_95(u,i,j,k) = mean((dtw_95 - latency_diff).^2);
                    temp_baseline_mse(u,i,j,k) = mean((baselineLat - latency_diff).^2);
                    temp_frac_peak_mse(u,i,j,k) = mean((fracPeakLat - latency_diff).^2);
                    temp_peak_lat_mse(u,i,j,k) = mean((peakLat - latency_diff).^2);
                    temp_peak_area_mse(u,i,j,k) = mean((areaLat - latency_diff).^2);
                    
                    
                end
            end
        end
    end
    %disp('Completed SNR: ' + string(t))
    dtw_mse_median(t,:,:,:,:) = temp_dtw_mse_median;
    dtw_mse_weighted_median(t,:,:,:,:) = temp_dtw_mse_weighted_median;
    dtw_mse_95(t,:,:,:,:) = temp_dtw_mse_95;
    baseline_mse(t,:,:,:,:) = temp_baseline_mse;
    frac_peak_mse(t,:,:,:,:) = temp_frac_peak_mse;
    peak_lat_mse(t,:,:,:,:) = temp_peak_lat_mse;
    peak_area_mse(t,:,:,:,:) = temp_peak_area_mse;
end

expParams = struct();
expParams.components = n_components;
expParams.latency_difference = latency_difference;
expParams.sig_length = sig_length;
expParams.SNRs = SNRs;

save('Results\data\expParams', 'expParams', '-v7.3')
save('Results\data\dtw_mse_median.mat', 'dtw_mse_median', '-v7.3')
save('Results\data\dtw_mse_weighted_median.mat', 'dtw_mse_weighted_median', '-v7.3')
save('Results\data\dtw_mse_95.mat', 'dtw_mse_95', '-v7.3')
save('Results\data\baseline_mse.mat', 'baseline_mse', '-v7.3')
save('Results\data\frac_peak_mse.mat', 'frac_peak_mse', '-v7.3')
save('Results\data\peak_lat_mse.mat', 'peak_lat_mse', '-v7.3')
save('Results\data\peak_area_mse.mat', 'peak_area_mse', '-v7.3')

