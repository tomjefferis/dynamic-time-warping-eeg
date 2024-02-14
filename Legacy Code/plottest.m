%% ERP Signal Generator with Sliders

addpath generate_signals/
addpath funcs/

% Parameters
sample_rate = 250;
signal_duration = 0.6;
baseline_duration = 0.1;
variance = 0.2;
SNR = 0.8;

% Create UI figure
uiFig = uifigure('Name', 'ERP Signal Generator', 'Position', [100, 100, 1580, 720]);

% ERP Plot
erp_plot = axes(uiFig);
title(erp_plot, 'ERP Signal');
xlabel(erp_plot, 'Time');
ylabel(erp_plot, 'Amplitude');
%get position
pos = erp_plot.Position;
erp_plot.Position = [pos(1)*1.2, pos(2), pos(3), pos(4)];


% Sample Rate Slider
sample_rate_slider = uislider(uiFig);
sample_rate_slider.Limits = [200 1000];
sample_rate_slider.Value = sample_rate;
sample_rate_slider.Position = [25, 600, 150, 3];
sample_rate_label = uilabel(uiFig, 'Text', 'Sample Rate:');
sample_rate_label.Position = [25, 610, 150, 20];

% Signal Duration Slider
signal_duration_slider = uislider(uiFig);
signal_duration_slider.Limits = [0.1 2];
signal_duration_slider.Value = signal_duration;
signal_duration_slider.Position = [25, 530, 150, 3];
signal_duration_label = uilabel(uiFig, 'Text', 'Signal Duration:');
signal_duration_label.Position = [25, 540, 150, 20];

% Baseline Duration Slider
baseline_duration_slider = uislider(uiFig);
baseline_duration_slider.Limits = [0 0.5];
baseline_duration_slider.Value = baseline_duration;
baseline_duration_slider.Position = [25, 460, 150, 3];
baseline_duration_label = uilabel(uiFig, 'Text', 'Baseline Duration:');
baseline_duration_label.Position = [25, 470, 150, 20];

% Variance Slider
variance_slider = uislider(uiFig);
variance_slider.Limits = [0 1];
variance_slider.Value = variance;
variance_slider.Position = [25, 390, 150, 3];
variance_label = uilabel(uiFig, 'Text', 'Variance:');
variance_label.Position = [25, 400, 150, 20];

% SNR Slider
SNR_slider = uislider(uiFig);
SNR_slider.Limits = [0 1];
SNR_slider.Value = SNR;
SNR_slider.Position = [25, 320, 150, 3];
SNR_label = uilabel(uiFig, 'Text', 'SNR:');
SNR_label.Position = [25, 330, 150, 20];

% Update Function
updatePlot = @(source, event) plotERP(...
    sample_rate_slider.Value, ...
    signal_duration_slider.Value, ...
    baseline_duration_slider.Value, ...
    variance_slider.Value, ...
    SNR_slider.Value, ...
    erp_plot);

% Value Changed Listeners
addlistener(sample_rate_slider, 'ValueChanged', updatePlot);
addlistener(signal_duration_slider, 'ValueChanged', updatePlot);
addlistener(baseline_duration_slider, 'ValueChanged', updatePlot);
addlistener(variance_slider, 'ValueChanged', updatePlot);
addlistener(SNR_slider, 'ValueChanged', updatePlot);

% Initial Plot
updatePlot();


function plotERP(sample_rate, signal_duration, baseline_duration, variance, SNR, erp_plot)
    % Time vector
    time = 0:1/sample_rate:signal_duration-1/sample_rate;

    % Generate clean ERP signal with adjusted components
    p1_amplitude = 1 + variance * abs(randn()); % Adjusted P1 amplitude with randomness
    p2_amplitude = 0.75 + variance * abs(randn());
    n1_amplitude = -1.25 + variance * abs(randn()); % Adjusted N1 amplitude with randomness
    p3_amplitude = 1.25 + variance * abs(randn()); % Adjusted P3 amplitude with randomness

    baseline = zeros(1, round(baseline_duration * sample_rate)); % Baseline period

    p1 = p1_amplitude * exp(-(time - 0.05).^2 / (2 * 0.01^2)); % Adjusted P1 component
    p2 = p2_amplitude * exp(-(time - 0.11).^2 / (2 * 0.01^2));
    n1 = n1_amplitude * exp(-(time - 0.085).^2 / (2 * 0.015^2)); % Adjusted N1 component
    p3 = p3_amplitude * exp(-(time - 0.3).^2 / (2 * 0.1^2)); % Adjusted P3 component

    erp_signal = [baseline, p1 + n1 + p2 + p3]; % Add baseline period to the ERP signal
    my_noise = noise(length(erp_signal), 1, sample_rate);
    erp_signal = erp_signal + (1-SNR)*my_noise;

       % Clear previous plot
    cla(erp_plot);

    time = 0:1/sample_rate:length(erp_signal)/sample_rate-1/sample_rate;

    % Plot ERP signal
    plot(erp_plot, time, erp_signal, 'LineWidth', 2);
    xlim([0, time(end)])
    title(erp_plot, 'ERP Signal');
    xlabel(erp_plot, 'Time');
    ylabel(erp_plot, 'Amplitude');
end