addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
addpath('W:\PhD\MatlabPlugins\spm12') % path to spm
addpath("C:\Users\Tom\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Patchline")
addpath("funcs\")
addpath(genpath('SEREEGA\'))

fs = 1000; % sample rate
sig_length = 1; % time in S
maxlats = [-20,20];
offset_latency = 30;
SNRD = 1;

% participant group 1
n_parts_1 = 7;
erp_1 = struct();
erp_1.peakAmplitude = [3,-6,3,-2,7]/1.5;
erp_1.peakLatency = [220,300,330,380,670];
erp_1.peakWidth = [65,70,56,55,600];
erp_1.probability = 1;
erp_1.type = 'erp';
erp_1.probabilitySlope = 0;
erp_1 = utl_check_class(erp_1);

% participant group 2
n_parts_2 = 3;
erp_2 = struct();
erp_2.peakAmplitude = erp_1.peakAmplitude*2;
erp_2.peakLatency = erp_1.peakLatency + offset_latency;
erp_2.peakWidth = erp_1.peakWidth;
erp_2.probability = 1;
erp_2.type = 'erp';
erp_2.probabilitySlope = 0;
erp_2 = utl_check_class(erp_2);

epochs = struct();
epochs.n = 1;             % the number of epochs to simulate
epochs.srate = fs;        % their sampling rate in Hz
epochs.length = sig_length*fs;       % their length in ms

noise = struct( ...
            'type', 'noise', ...
            'color', 'pink', ...
            'amplitude', max(abs(erp_2.peakAmplitude)/SNRD));
noise = utl_check_class(noise);

erps_1 = [];
latency_offsets_1 = [];

for i = 1:n_parts_1
    erp_1_temp = erp_1;
    latency_shift = randi(maxlats);
    latency_offsets_1 = [latency_offsets_1; latency_shift];
    erp_1_temp.peakLatency = erp_1_temp.peakLatency + latency_shift;

    sig1 = generate_signal_fromclass(erp_1_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig1 = filter(B,A,sig1)';

    erps_1 = [erps_1, sig1];
end

erps_2 = [];
latency_offsets_2 = [];

for i = 1:n_parts_2
    erp_2_temp = erp_2;
    latency_shift = randi(maxlats);
    latency_offsets_2 = [latency_offsets_2; latency_shift + offset_latency];
    erp_2_temp.peakLatency = erp_2_temp.peakLatency + latency_shift;

    sig2 = generate_signal_fromclass(erp_2_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig2 = filter(B,A,sig2)';

    erps_2 = [erps_2, sig2];
end

% Combine both groups into a single dataset for analysis
erps_combined = [erps_1, erps_2];
latencies_combined = [latency_offsets_1; latency_offsets_2];
n_total = n_parts_1 + n_parts_2;

% Plot individual ERPs
figure
for i = 1:size(erps_combined,2)
    plot(1:fs, erps_combined(:,i), 'LineWidth', 2)
    hold on
end
title("ERPs to use in jackknife procedure")
xlabel("Time (ms)")
ylabel("Voltage (uV)")

% Plot representative ERPs from each group
figure
plot(1:fs, erps_1(:,1), 'LineWidth', 2)
hold on
plot(1:fs, erps_2(:,1), 'LineWidth', 2)
legend("P1 (early low amplitude)", "P2 (late high amplitude)")
title("Example of ERPs for participant groups 1 and 2")
xlabel("Time (ms)")
ylabel("Voltage (uV)")

% Generate jackknifed ERPs - treating all participants as one group
jackknifed_ERPs = [];
for i = 1:size(erps_combined,2)
    erps_temp = erps_combined;
    erps_temp(:,i) = [];
    jackknifed_ERPs = [jackknifed_ERPs, mean(erps_temp,2)];
end

% Plot jackknifed ERPs
figure
for i = 1:size(jackknifed_ERPs,2)
    plot(1:fs, jackknifed_ERPs(:,i), 'LineWidth', 2)
    hold on
end
title("Jackknifed ERPs")
xlabel("Time (ms)")
ylabel("Voltage (uV)")

% Define the window of interest for latency analysis (in ms)
window_start = 150;
window_end = 400;
fractional_area = 0.5; % 50% area latency

% Display the original latency offsets (ground truth)
fprintf('Original latency offsets: Mean = %.2f ms, SD = %.2f ms\n', ...
    range(latencies_combined), std(latencies_combined));

% Compute jackknifed latencies using area latency method
jackknife_latencies = compute_area_latency(jackknifed_ERPs, window_start, window_end, fs, fractional_area);

% Calculate jackknife statistics
% Miller et al. (1998) jackknife correction formula: SD_j = sqrt(n_total-1) * SD
jackknife_corrected_std = sqrt(n_total-1) * std(jackknife_latencies);

% Display jackknife mean and corrected std
fprintf('Jackknife area latencies: Mean = %.2f ms, Corrected SD = %.2f ms\n', ...
    range(jackknife_latencies), jackknife_corrected_std);


% use the dynamic time warping function to get latencies from every participant to every other participant
% then print the range and standard deviation of the latencies
dtw_latencies = zeros(n_total, n_total);
for i = 1:n_total
    for j = 1:n_total
        [maxlatmedian, ~, ~]= dynamictimewarper(erps_combined(window_start:window_end,i)',erps_combined(window_start:window_end,j)',fs,true);
        dtw_latencies(i,j) = maxlatmedian;
    end
end
% range and standard deviation of the latencies
fprintf('DTW latencies: Range = %.2f ms, SD = %.2f ms\n', ...
    mean(range(dtw_latencies))*fs, mean(std(dtw_latencies))*fs);

% Create a helper function to compute area latency
function latencies = compute_area_latency(data, window_start, window_end, fs, fractional_area)
    latencies = zeros(1, size(data, 2));
    
    for i = 1:size(data, 2)
        % Extract the windowed signal
        signal = data(window_start:window_end, i);
        
        % Find the absolute area under the curve
        abs_area = sum(abs(signal));
        target_area = abs_area * fractional_area;
        
        % Find the sample where fractional area is reached
        cum_area = cumsum(abs(signal));
        [~, area_idx] = min(abs(cum_area - target_area));
        
        % Return latency in milliseconds (assuming data is in samples)
        latencies(i) = window_start + area_idx - 1;
    end
end

