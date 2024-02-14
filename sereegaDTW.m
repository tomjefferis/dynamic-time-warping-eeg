%% adding paths
addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip

%% Script config
% script parameters
n_permutations = 1000;
% Source parameters
N_locations = 10; % number of potential source generators
location_distance = 50; % minimum disrtance between generators mm
% Component parameters
latency_difference = [-0.1:0.01:0.1];
n_components = [1:10]; 
component_widths = [25:200];
min_amplitude = -1;
max_amplitude = 1; 
component_range = [200:800]; % componet range within signal
SNR = 0.2; % Signal to noise ratio
fs = 1000; % sample rate
sig_length = [0.8:0.2:3]; % time in S
amplitude_variability = 0.1; % variability of amplitude


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


for u = 1:length(n_components)
    n_component = n_components(u);
    for i = 1:length(sig_length)
        sig_len = sig_length(i);
        for j = 1:length(latency_difference)
            latency_diff = latency_difference(j);
            for k = 1:n_permutations
            
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
                    scalpdata = generate_scalpdata(c, lf, epochs);

                    c = struct();
                    c.source = sourcelocs;      % obtained from the lead field, as above
                    c.signal = {erp2,noise};       % ERP class, defined above
                    c = utl_check_component(c, lf);
                    scalpdata2 = generate_scalpdata(c, lf, epochs);


                    % determine latency difference
                    
                    
            end
        end
    end
end





