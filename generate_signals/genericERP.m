function erp_signal = genericERP(sample_rate, signal_duration, baseline_duration, variance,SNR)
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
end
