function erp_signal = genericERP(sample_rate, signal_duration, baseline_duration)
    % Time vector
    time = 0:1/sample_rate:signal_duration-1/sample_rate;

    % Generate clean ERP signal with adjusted components
    p1_amplitude = 2; % Adjusted P1 amplitude
    p2_amplitude = 1.8;
    n1_amplitude = -3; % Adjusted N1 amplitude
    p3_amplitude = 3; % Adjusted P3 amplitude

    baseline = zeros(1, round(baseline_duration * sample_rate)); % Baseline period

    p1 = p1_amplitude * exp(-(time - 0.1).^2 / (2 * 0.02^2)); % Adjusted P1 component
    p2 = p2_amplitude * exp(-(time - 0.2).^2 / (2 * 0.02^2));
    n1 = n1_amplitude * exp(-(time - 0.17).^2 / (2 * 0.03^2)); % Adjusted N1 component
    p3 = p3_amplitude * exp(-(time - 0.9).^2 / (2 * 0.2^2)); % Adjusted P3 component

    erp_signal = [baseline, p1 + n1 + p2 + p3]; % Add baseline period to the ERP signal
end
