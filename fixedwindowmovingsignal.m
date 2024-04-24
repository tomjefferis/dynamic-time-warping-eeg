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
    allwinLocs = [allwinLocs, 0:window_widths(i)/2:sig_length-window_widths(i)];
end


% result arrays
dtw_mse_median = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
dtw_mse_weighted_median = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
dtw_mse_95 = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
baseline_mse = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
frac_peak_mse = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
peak_lat_mse = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);
peak_area_mse = NaN(length(SNRs),length(sig_length), length(latency_difference), length(window_widths),length(allwinLocs), n_signals_generate);

for i = 1:length(SNRs)
    SNR = SNRs(i);
    
    for j = 1:length(latency_difference)
        latency_diff = latency_difference(j);
        for k = 1:length(window_widths)
            
            window_width = window_widths(k);
            
            
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
                
                erp.peakLatency = erp.peakLatency + latency_difference*fs;
                
                sig2 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);
                

                window_location = 0:window_width/2:sig_length-window_width;
                for l = 1:length(window_location)
                    window_start = window_location(l)*fs;
                    window_end = window_start + window_width*fs;
                    
                    sig1_window = sig1(window_start:window_end);
                    sig2_window = sig2(window_start:window_end);


                end
            end
        end
    end
end
    
    %% Questions to ask Howard
    % 1. How to implement the amplitude variability
    % 2. How to implement the SNR
    % 3. How to implement the windowing, should i test each size window in each location?
    % 4. How to implement the jitter between components, if jitter too big would make component latency 0
    
