function erp_signal = genericERP(sample_rate, signal_duration, baseline_duration, variance, SNR, params)

    % if params is not provided, use default values
    if nargin < 6
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
    else
        % check params
        [valid,params] = checkParams(params);
        if ~valid
            error('Invalid parameters');
            return;
        end

        time = 0:1/sample_rate:signal_duration-1/sample_rate;

        peaks = {};
        for i = 1:params.n_peaks
            amp = params.peak_amplitudes(i) + variance * abs(randn());
            peaks{i} = amp * exp(-(time - params.peak_latencies(i)).^2 / (2 * params.peak_widths(i)^2));
        end

        troughs = {};
        for i = 1:params.n_troughs
            amp = params.trough_amplitudes(i) + variance * abs(randn());
            troughs{i} = amp * exp(-(time - params.trough_latencies(i)).^2 / (2 * params.trough_widths(i)^2));
        end

        baseline = zeros(1, round(baseline_duration * sample_rate));

        erp_signal = baseline;
        for i = 1:params.n_peaks
            erp_signal = erp_signal + peaks{i};
        end
        for i = 1:params.n_troughs
            erp_signal = erp_signal + troughs{i};
        end
        my_noise = noise(length(erp_signal), 1, sample_rate);
        erp_signal = erp_signal + (1-SNR)*my_noise;

    end
        
end



function [valid,params] =  checkParams(params)
    valid = false;

    if ~isfield(params, 'n_peaks')
        params.n_peaks = 3;
    end
    if ~isfield(params, 'peak_amplitudes')
        params.peak_amplitudes = [1, 0.75, 1.25];
    end
    if ~isfield(params, 'peak_latencies')
        params.peak_latencies = [0.05, 0.11, 0.3];
    end
    if ~isfield(params, 'peak_widths')
        params.peak_widths = [0.01, 0.01, 0.1];
    end
    if length(params.peak_amplitudes) ~= params.n_peaks || length(params.peak_latencies) ~= params.n_peaks ...
        || length(params.peak_widths) ~= params.n_peaks
        error('Length of peak_amplitudes, peak_latencies, and peak_widths must be equal to n_peaks');
        return;
    end
    if ~isfield(params, 'n_troughs')
        params.n_troughs = 2;
    end
    if ~isfield(params, 'trough_amplitudes')
        params.trough_amplitudes = [-1.25, -1.25];
    end
    if ~isfield(params, 'trough_latencies')
        params.trough_latencies = [0.085, 0.2];
    end
    if ~isfield(params, 'trough_widths')
        params.trough_widths = [0.015, 0.05];
    end
    if length(params.trough_amplitudes) ~= params.n_troughs || length(params.trough_latencies) ~= params.n_troughs ...
        || length(params.trough_widths) ~= params.n_troughs
        error('Length of trough_amplitudes, trough_latencies, and trough_widths must be equal to n_troughs');
        return;
    end

    for i = 1:params.n_peaks
        if params.peak_amplitudes(i) < 0
            error('Peak amplitudes must be non-negative');
            return;
        end
        if params.peak_widths(i) <= 0
            error('Peak widths must be positive');
            return;
        end
    end
    for i = 1:params.n_troughs
        if params.trough_amplitudes(i) > 0
            error('Trough amplitudes must be non-positive');
            return;
        end
        if params.trough_widths(i) <= 0
            error('Trough widths must be positive');
            return;
        end
    end

    valid = true;
    return;


end