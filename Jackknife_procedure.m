addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
addpath('W:\PhD\MatlabPlugins\spm12') % path to spm
addpath("C:\Users\Tom\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Patchline")
addpath("funcs\")
addpath(genpath('SEREEGA\'))

fs = 1000; % sample rate
sig_length = 1; % time in S
maxlats = [-20,20];


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
erp_2.peakLatency = erp_1.peakLatency + 50;
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
            'amplitude', max(abs(erp_2.peakAmplitude)/5));
        noise = utl_check_class(noise);


erps_1 = [];
erps_2 = [];
latency_offsets = [];

for i = 1:n_parts_1
    erp_1_temp = erp_1;
    latency_shift = randi(maxlats);
    latency_offsets = [latency_offsets; latency_shift];
    erp_1_temp.peakLatency = erp_1_temp.peakLatency + latency_shift;

    sig1 = generate_signal_fromclass(erp_1_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig1 = filter(B,A,sig1)';

    erps_1 = [erps_1, sig1];
end

latency_offsets_2 = [];
for i = 1:n_parts_2
    erp_2_temp = erp_2;
    latency_shift = randi(maxlats);
    latency_offsets_2 = [latency_offsets_2; latency_shift];
    erp_2_temp.peakLatency = erp_2_temp.peakLatency + latency_shift;

    sig2 = generate_signal_fromclass(erp_2_temp, epochs) + generate_signal_fromclass(noise, epochs);

    N = 2; 
    [B,A] = butter(N,[1 30]/(fs/2));
    sig2 = filter(B,A,sig2)';

    erps_2 = [erps_2, sig2];
end

erps_combined = [erps_1, erps_2];

% plot the data on same plot, linewidth 2
figure
for i = 1:size(erps_combined,2)
    plot(1:fs, erps_combined(:,i), 'LineWidth', 2)
    hold on
end
title("ERPs to use in jackknife procedure")
xlabel("Time (ms)")
ylabel("Voltage (uV)")

% plot an example of erp_1 and erp_2
figure
plot(1:fs, erps_1(:,1), 'LineWidth', 2)
hold on
plot(1:fs, erps_2(:,1), 'LineWidth', 2)
legend("P1 (early low amplitude)", "P2 (late high amplitude)")
title("Example of ERPs for participant groups 1 and 2")
xlabel("Time (ms)")
ylabel("Voltage (uV)")

jackknifed_ERPs = [];
for i = 1:size(erps_combined,2)
    erps_temp = erps_combined;
    erps_temp(:,i) = [];
    jackknifed_ERPs = [jackknifed_ERPs, mean(erps_temp,2)];
end

% plot the data on same plot, linewidth 2
figure
for i = 1:size(jackknifed_ERPs,2)
    plot(1:fs, jackknifed_ERPs(:,i), 'LineWidth', 2)
    hold on
end

%% TODO: analyse jackknife latencies for the window of interest
% 1. Compute the latencies for each participant
% 2. Compute the mean and standard deviation of the latencies
% 3. Compute the jackknife latencies
% 4. Compute the mean and standard deviation of the jackknife latencies
% 5. Compute the bias and variance of the jackknife latencies
% 6. Compute the confidence intervals of the jackknife latencies
% 7. Plot the jackknife latencies

%% then compare this between DTW