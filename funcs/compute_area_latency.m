% filepath: /c:/Users/Tom/Documents/GitHub/dynamic-time-warping-eeg/funcs/compute_area_latency.m
function latency = compute_area_latency(erp_data, window_start, window_end, fs, fractional_area)
    % COMPUTE_AREA_LATENCY Calculate the area latency of ERP data
    %
    % Inputs:
    %   erp_data        - ERP data matrix (time x channels)
    %   window_start    - Start time of analysis window in ms
    %   window_end      - End time of analysis window in ms
    %   fs              - Sampling rate in Hz
    %   fractional_area - Fraction of area to use (default: 0.5 for 50%)
    %
    % Outputs:
    %   latency         - Calculated latency in ms for each channel
    
    % Set default fractional area if not provided
    if nargin < 5
        fractional_area = 0.5;
    end
    
    % Convert window times from ms to sample indices
    start_idx = max(1, round(window_start * fs/1000));
    end_idx = min(size(erp_data, 1), round(window_end * fs/1000));
    
    % Initialize latency output array
    num_channels = size(erp_data, 2);
    latency = zeros(1, num_channels);
    
    for ch = 1:num_channels
        % Extract data in the window
        signal = erp_data(start_idx:end_idx, ch);
        
        % Calculate the absolute area under the curve
        abs_signal = abs(signal);
        total_area = sum(abs_signal);
        
        if total_area == 0
            % If there's no area, use the midpoint of the window
            latency(ch) = (window_start + window_end) / 2;
            continue;
        end
        
        % Calculate the cumulative area
        cum_area = cumsum(abs_signal);
        
        % Find the point at which the cumulative area reaches the target fraction
        target_area = total_area * fractional_area;
        [~, idx] = min(abs(cum_area - target_area));
        
        % Convert back to ms
        latency_sample = start_idx + idx - 1;
        latency(ch) = latency_sample * 1000 / fs;
    end
    
    end