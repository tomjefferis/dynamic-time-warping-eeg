addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
addpath('W:\PhD\MatlabPlugins\spm12') % path to spm
addpath("C:\Users\Tom\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Patchline")
addpath("funcs\")
addpath(genpath('SEREEGA\'))

fs = 1000; % sample rate
sig_length = 1; % time in S
maxlats = [-20,20];
offset_latency = 30;
SNRD = 4;
n_parts = 5;
n_p_change = [3];
off_amp = 4;

% participant group 1

erp_1 = struct();
erp_1.peakAmplitude = [3,-6,3,-2,7];
erp_1.peakLatency = [220,300,330,380,670];
erp_1.peakWidth = [65,70,56,55,600];
erp_1.probability = 1;
erp_1.type = 'erp';
erp_1.probabilitySlope = 0;
erp_1 = utl_check_class(erp_1);

% participant group 2

erp_2 = struct();
erp_2.peakAmplitude = [3,-6,3,-2,7];
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

for i = 1:n_parts
    erp_1_temp = erp_1;
    latency_shift = randi(maxlats);
    latency_offsets_1 = [latency_offsets_1; latency_shift];
    erp_1_temp.peakLatency = erp_1_temp.peakLatency + latency_shift;

    if ismember(i,n_p_change)
        erp_1_temp.peakAmplitude(2) = erp_1_temp.peakAmplitude(2) * off_amp;
    end

    sig1 = generate_signal_fromclass(erp_1_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig1 = filter(B,A,sig1)';

    erps_1 = [erps_1, sig1];
end

erps_2 = [];
latency_offsets_2 = [];

for i = 1:n_parts
    erp_2_temp = erp_2;
    latency_shift = randi(maxlats);
    latency_offsets_2 = [latency_offsets_2; latency_shift + offset_latency];
    erp_2_temp.peakLatency = erp_2_temp.peakLatency + latency_shift;

    if ismember(i,n_p_change)
        erp_2_temp.peakAmplitude(2) = erp_2_temp.peakAmplitude(2) * off_amp;
    end

    sig2 = generate_signal_fromclass(erp_2_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig2 = filter(B,A,sig2)';

    erps_2 = [erps_2, sig2];
end

% Keep groups separate instead of combining
erps_combined = [erps_1, erps_2]; % Only used for overall dataset
latencies_combined = [latency_offsets_1; latency_offsets_2]; % Ground truth latencies
n_total = n_parts *2;

% Generate jackknifed ERPs for each group separately
jackknifed_ERPs_1 = [];
for i = 1:size(erps_1,2)
    erps_temp = erps_1;
    erps_temp(:,i) = [];
    jackknifed_ERPs_1 = [jackknifed_ERPs_1, mean(erps_temp,2)];
end

jackknifed_ERPs_2 = [];
for i = 1:size(erps_2,2)
    erps_temp = erps_2;
    erps_temp(:,i) = [];
    jackknifed_ERPs_2 = [jackknifed_ERPs_2, mean(erps_temp,2)];
end

% Define the window of interest for latency analysis (in ms)
window_start = 150;
window_end = 400;
fractional_area = 0.5; % 50% area latency

% Display the original latency offsets for each group (ground truth)
fprintf('Group 1 original latency offsets: Range = %.2f ms, SD = %.2f ms\n', ...
    range(latency_offsets_1), std(latency_offsets_1));
fprintf('Group 2 original latency offsets: Range = %.2f ms, SD = %.2f ms\n', ...
    range(latency_offsets_2), std(latency_offsets_2));
fprintf('True latency difference between groups: %.2f ms\n', ...
    mean(latency_offsets_2) - mean(latency_offsets_1));

% Compute jackknifed latencies for each group using area latency method
jackknife_latencies_1 = compute_area_latency(jackknifed_ERPs_1, window_start, window_end, fs, fractional_area);
jackknife_latencies_2 = compute_area_latency(jackknifed_ERPs_2, window_start, window_end, fs, fractional_area);

% Calculate jackknife statistics for each group
% Miller et al. (1998) jackknife correction formula: SD_j = sqrt(n-1) * SD
jackknife_corrected_std_1 = sqrt(n_parts-1) * std(jackknife_latencies_1);
jackknife_corrected_std_2 = sqrt(n_parts-1) * std(jackknife_latencies_2);

% Display jackknife mean and corrected std for each group
fprintf('Group 1 jackknife area latencies: Mean = %.2f ms, Corrected SD = %.2f ms\n', ...
    mean(jackknife_latencies_1), jackknife_corrected_std_1);
fprintf('Group 2 jackknife area latencies: Mean = %.2f ms, Corrected SD = %.2f ms\n', ...
    mean(jackknife_latencies_2), jackknife_corrected_std_2);

% Calculate the estimated latency difference between groups using jackknife
jackknife_latency_diff = mean(jackknife_latencies_2) - mean(jackknife_latencies_1);
fprintf('Jackknife estimated latency difference between groups: %.2f ms\n', jackknife_latency_diff);

% Calculate the standard error of the difference using pooled variance
pooled_var = (jackknife_corrected_std_1^2/n_parts) + (jackknife_corrected_std_2^2/n_parts);
diff_se = sqrt(pooled_var);
fprintf('Standard error of the latency difference: %.2f ms\n', diff_se);

% Calculate 95% confidence interval for the difference
t_critical = tinv(0.975, n_parts + n_parts - 2);
ci_lower = jackknife_latency_diff - t_critical * diff_se;
ci_upper = jackknife_latency_diff + t_critical * diff_se;
fprintf('95%% CI for latency difference: [%.2f, %.2f] ms\n', ci_lower, ci_upper);

% Use dynamic time warping to compare each participant in group 1 to each in group 2
dtw_cross_group = zeros(n_parts, n_parts);
for i = 1:n_parts
    for j = 1:n_parts
        [maxlatmedian, ~, ~] = dynamictimewarper(erps_1(window_start:window_end,i)', ...
            erps_2(window_start:window_end,j)', fs, false);
        dtw_cross_group(i,j) = maxlatmedian;
    end
end

% Calculate the mean DTW latency difference between groups
mean_dtw_diff = mean(dtw_cross_group(:)) * fs;
fprintf('DTW estimated mean latency difference between groups: %.2f ms\n', abs(mean_dtw_diff));

% Calculate grand averages
grand_avg_1 = mean(erps_1, 2);
grand_avg_2 = mean(erps_2, 2);
mean_lat_1 = window_start + mean(jackknife_latencies_1);
mean_lat_2 = window_start + mean(jackknife_latencies_2);

% Create a single plot with all signals
figure('Position', [100, 100, 1000, 600])

% Plot individual ERPs with transparency
for i = 1:size(erps_1,2)
    plot(1:fs, erps_1(:,i), 'LineWidth', 1, 'Color', [0.8, 0.2, 0.2, 0.3])
    hold on
end

for i = 1:size(erps_2,2)
    plot(1:fs, erps_2(:,i), 'LineWidth', 1, 'Color', [0.2, 0.2, 0.8, 0.3])
    hold on
end

% Plot grand averages with higher line width
plot(1:fs, grand_avg_1, 'LineWidth', 3, 'Color', [0.8, 0.2, 0.2])
plot(1:fs, grand_avg_2, 'LineWidth', 3, 'Color', [0.2, 0.2, 0.8])

% Mark the estimated latencies
y_lim = get(gca, 'YLim');
plot([mean_lat_1, mean_lat_1], y_lim, '--', 'Color', [0.8, 0.2, 0.2], 'LineWidth', 1.5)
plot([mean_lat_2, mean_lat_2], y_lim, '--', 'Color', [0.2, 0.2, 0.8], 'LineWidth', 1.5)

% Add labels and title
title(sprintf('All ERP Signals with Latency Estimates (Difference: %.2f ms)', jackknife_latency_diff))
xlabel('Time (ms)')
ylabel('Amplitude (μV)')
legend([{'Group 1 Individual', 'Group 2 Individual', 'Group 1 Average', 'Group 2 Average', ...
         'Group 1 Latency', 'Group 2 Latency'}])
grid on

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
        
        % Return latency (sample index relative to window start)
        latencies(i) = area_idx;
    end
end

