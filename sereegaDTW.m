%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
% script parameters
n_signals_generate = 10000; 
% Component parameters
latency_difference = -0.1:0.01:0.1;
n_components = 1:8; 
component_widths = 25:250;
min_amplitude = -10;
max_amplitude = 10; 
SNR = 0.3; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs
fs = 1000; % sample rate
sig_length = 0.3:0.1:3; % time in S
amplitude_variability = 0.1; % variability of amplitude, not implemented yet


% result arrays
dtw_mse_median = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
dtw_mse_weighted_median = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
dtw_mse_95 = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
baseline_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
frac_peak_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
peak_lat_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);
peak_area_mse = ones(length(sig_length), length(n_components), length(latency_difference), n_signals_generate);



parfor u = 1:length(sig_length)
    sig_len = sig_length(u);
    
    temp_dtw_mse_median = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_dtw_mse_weighted_median = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_dtw_mse_95 = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_baseline_mse = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_frac_peak_mse = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_peak_lat_mse = ones(length(n_components), length(latency_difference), n_signals_generate);
    temp_peak_area_mse = ones(length(n_components), length(latency_difference), n_signals_generate);

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

                    
                    data = struct();
                    data.erp = ft_preproc_bandpassfilter(data1,fs,[1 30])';
                    data2 = struct();
                    data2.erp = ft_preproc_bandpassfilter(data2_t,fs,[1 30])';
                    
                    
                    % determine latency difference
                    [dtw_median, dtw_weighted_median, dtw_95] = dynamictimewarper(data2, data, fs);
                    peakLat = peaklatency(data2,data,fs);
                    fracPeakLat = fracpeaklatency(data2,data,fs);
                    areaLat = peakArea(data2,data,fs, 0.5, baselines);
                    baselineLat = baselineDeviation(data2,data,fs, baselines,2);

                    % get mse for each metric
                    temp_dtw_mse_median(i,j,k) = mean((dtw_median - latency_diff).^2);
                    temp_dtw_mse_weighted_median(i,j,k) = mean((dtw_weighted_median - latency_diff).^2);
                    temp_dtw_mse_95(i,j,k) = mean((dtw_95 - latency_diff).^2);
                    temp_baseline_mse(i,j,k) = mean((baselineLat - latency_diff).^2);
                    temp_frac_peak_mse(i,j,k) = mean((fracPeakLat - latency_diff).^2);
                    temp_peak_lat_mse(i,j,k) = mean((peakLat - latency_diff).^2);
                    temp_peak_area_mse(i,j,k) = mean((areaLat - latency_diff).^2);
                                       
                    
            end
        end
    end

    dtw_mse_median(u,:,:,:) = temp_dtw_mse_median;
    dtw_mse_weighted_median(u,:,:,:) = temp_dtw_mse_weighted_median;
    dtw_mse_95(u,:,:,:) = temp_dtw_mse_95;
    baseline_mse(u,:,:,:) = temp_baseline_mse;
    frac_peak_mse(u,:,:,:) = temp_frac_peak_mse;
    peak_lat_mse(u,:,:,:) = temp_peak_lat_mse;
    peak_area_mse(u,:,:,:) = temp_peak_area_mse;
    
end



save('Results\data\dtw_mse_median.mat', 'dtw_mse_median')
save('Results\data\dtw_mse_weighted_median.mat', 'dtw_mse_weighted_median')
save('Results\data\dtw_mse_95.mat', 'dtw_mse_95')
save('Results\data\baseline_mse.mat', 'baseline_mse')
save('Results\data\frac_peak_mse.mat', 'frac_peak_mse')
save('Results\data\peak_lat_mse.mat', 'peak_lat_mse')
save('Results\data\peak_area_mse.mat', 'peak_area_mse')

