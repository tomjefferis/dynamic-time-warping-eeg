%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\

%% Script config
% script parameters
n_permutations = 10;
% Source parameters
N_locations = 10; % number of potential source generators
location_distance = 50; % minimum disrtance between generators mm
% Component parameters
latency_difference = -0.05:0.01:0.05;
n_components = 1:10; 
component_widths = 25:200;
min_amplitude = -10;
max_amplitude = 10; 
SNR = 0.3; % Signal to noise ratio, leaving at 0.3 for 'good looking' ERPs
fs = 1000; % sample rate
sig_length = 0.3:0.2:3; % time in S
amplitude_variability = 0.1; % variability of amplitude, not implemented yet


% loading pre generated leadfield
lf = lf_generate_fromnyhead('montage', 'S64');
% result arrays
dtw_mse_median = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
dtw_mse_weighted_median= zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
dtw_mse_95 = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
baseline_mse = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
frac_peak_mse = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
peak_lat_mse = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);
peak_area_mse = zeros(length(n_components), length(sig_length), length(latency_difference), n_permutations);


parfor u = 1:length(n_components)
    n_component = n_components(u);
    
    temp_dtw_mse_median = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_dtw_mse_weighted_median = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_dtw_mse_95 = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_baseline_mse = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_frac_peak_mse = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_peak_lat_mse = zeros(length(sig_length), length(latency_difference), n_permutations);
    temp_peak_area_mse = zeros(length(sig_length), length(latency_difference), n_permutations);

    for i = 1:length(sig_length)
        sig_len = sig_length(i);
        for j = 1:length(latency_difference)
            latency_diff = latency_difference(j);
            for k = 1:n_permutations

                    
                    component_range = round(sig_len*fs*0.3) : round(sig_len*fs*0.8);
                    
                    if sig_len*fs < 500
                        baselines = 10;
                    else
                        baselines = round(sig_len*fs*0.1);
                    end
                    
                    sourcelocs  = lf_get_source_spaced(lf, N_locations, location_distance);
                    amps = [min_amplitude:.1:min_amplitude/2, max_amplitude/2:.1:max_amplitude];
                    erp = erp_get_class_random(n_component, component_range, component_widths, amps);

                    % erp2 with added latency difference
                    erp2 = erp;
                    erp2.peakLatency = erp2.peakLatency + round(latency_diff*fs);

                    noise = struct( ...
                            'type', 'noise', ...
                            'color', 'pink', ...
                            'amplitude', max(abs(min_amplitude),abs(max_amplitude))*SNR);
                    noise = utl_check_class(noise);

                    epochs = struct();
                    epochs.n = 1;             % the number of epochs to simulate
                    epochs.srate = fs;        % their sampling rate in Hz
                    epochs.length = sig_len*fs;       % their length in ms

                    % combining into components
                    c = struct();
                    c.source = sourcelocs;      % obtained from the lead field, as above
                    c.signal = {erp,noise};       % ERP class, defined above

                    c = utl_check_component(c, lf);
                    scpalpdata = generate_scalpdata(c, lf, epochs, 'useParallelPool', 0, 'showProgress', 0);

                    c = struct();
                    c.source = sourcelocs;      % obtained from the lead field, as above
                    c.signal = {erp2,noise};       % ERP class, defined above
                    c = utl_check_component(c, lf);
                    scalpdata2 = generate_scalpdata(c, lf, epochs, 'useParallelPool', 0, 'showProgress', 0);

                    EEG1 = utl_create_eeglabdataset(scalpdata, epochs, lf);
                    data1 = eeglab2fieldtrip(EEG1, 'timelock', 'none');

                    EEG2 = utl_create_eeglabdataset(scalpdata2, epochs, lf);
                    data2_t = eeglab2fieldtrip(EEG2, 'timelock', 'none');

                    % get random electrode 
                    electrode = randi([1,size(data1.avg,1)],1,1);

                    
                    data = struct();
                    data.erp = ft_preproc_bandpassfilter(data1.avg(electrode,:),fs,[1 30])';
                    data2 = struct();
                    data2.erp = ft_preproc_bandpassfilter(data2_t.avg(electrode,:),fs,[1 30])';
                    
                    
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

