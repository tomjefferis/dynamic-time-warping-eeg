function [warpedLatencies, max_index] = fullVolumeWarperFieldTrip(data1, data2, analysis_window)
    % defines window and then steps through dtw for each electrode and window
    % assumes data1 is in the same order as data 2, i.e. data1(1) is the same participant as data2(1)
    %quick error check
    
    
    n_participants = length(data1);
    n_electrodes = length(data1{1}.label);
    signalLength = length(data1{1}.time);
    time = data1{1}.time;

    % find 0 in time vector
    zeroIndex = find(time == 0);
    % if there is no 0, find the closest value to 0
    if isempty(zeroIndex)
        [~, zeroIndex] = min(abs(time));
    end
    % get the sampling rate from the time vector
    fs = 1/(time(2) - time(1));

    % find start and end of the analysis window in the time vector
    start_analysis = 1;
    end_analysis = find(time == analysis_window(2));

    % if the analysis window is not in the time vector, find the closest values
    if isempty(end_analysis)
        [~, end_analysis] = min(abs(time - analysis_window(2)));
        end_analysis = end_analysis +1; % will not round up
    end

    %cut time vector to analysis window including baseline
    time = time(1:end_analysis);
    %cut data to analysis window including baseline
    for i = 1:n_participants
        data1{i}.avg = data1{i}.avg(:,start_analysis:end_analysis);
        data2{i}.avg = data2{i}.avg(:,start_analysis:end_analysis);
        data1{i}.time = time;
        data2{i}.time = time;
    end


    if n_participants ~= length(data2)
        error('data1 and data2 must have the same number of participants')
    end

    % define window sizes as 10% and 20% of the analysis window
    windowSizes = [round(abs((time(end_analysis) - time(start_analysis))) * 0.1 * fs), round(abs((time(end_analysis) - time(start_analysis))) * 0.2 * fs)];
    signalLength = length(data1{1}.time);
    warped_paths = data1; %we replave the .avg field with the warped latencies
    baseline = zeroIndex;

    % largest latency difference
    max_index = [];
    max_sig1 = [];
    max_sig2 = [];

    % for each participant
    for i = 1:n_participants
        warped_participant = warped_paths{i};
        % Initialize temporary storage for the warped latencies
        warped_latencies_all_windows = zeros(n_electrodes, signalLength, length(windowSizes));
        
        % for each window size
        for l = 1:length(windowSizes)
            
            windowSize = windowSizes(l);
            % for each electrode
            for j = 1:n_electrodes
                % get the data for the current electrode
                data1_temp = data1{i};
                data2_temp = data2{i};
                
                data1_erp = zscore(data1_temp.avg(j,:));
                data2_erp = zscore(data2_temp.avg(j,:));
    
                % baseline signal
                data1_baseline = mean(data1_erp(1:baseline));
                data2_baseline = mean(data2_erp(1:baseline));
    
                data1_erp = data1_erp - data1_baseline;
                data2_erp = data2_erp - data2_baseline;
                
                temp_warped = zeros(1, signalLength);
                
                for k = 1:signalLength
                    
                    % k is the index of the signal we are looking at
                    % want to use K as the center of the window and zero pad if this window goes out of bounds
                    if k - windowSize < 1
                        % Case 1: Window goes out of bounds on the left side
                        pad_left = abs(k - round(windowSize/2)) - 1;
                        data1_window = [zeros(1, pad_left), data1_erp(1:k+round(windowSize/2))];
                        data2_window = [zeros(1, pad_left), data2_erp(1:k+round(windowSize/2))];
                    elseif k + windowSize > signalLength
                        % Case 2: Window goes out of bounds on the right side
                        pad_right = k + round(windowSize/2) - signalLength;
                        data1_window = [data1_erp(k-round(windowSize/2):end), zeros(1, pad_right)];
                        data2_window = [data2_erp(k-round(windowSize/2):end), zeros(1, pad_right)];
                    else
                        % Case 3: Window is within bounds
                        data1_window = data1_erp(k-round(windowSize/2):k+round(windowSize/2));
                        data2_window = data2_erp(k-round(windowSize/2):k+round(windowSize/2));
                    end
                    
                    % Perform dynamic time warping
                    [maxlatmedian, ~, ~] = dynamictimewarper(data2_window, data1_window, fs,false);
                    
                    temp_warped(k) = maxlatmedian;
                    
                end
                
                % Store the warped latencies for this window size
                warped_latencies_all_windows(j, :, l) = temp_warped;
            end
        end
        
        % Compute the mean across the different window sizes
        mean_warped_all_windows = mean(warped_latencies_all_windows, 3);

        % get the average latency difference all windows
        maxlat_local = mean(mean_warped_all_windows(:));
        max_index = [max_index, maxlat_local];
        
        % Assign the mean values to the participant's warped paths
        warped_participant.avg = mean_warped_all_windows;
        warped_paths{i} = warped_participant;
    end
    
    warpedLatencies = warped_paths;
    
    end