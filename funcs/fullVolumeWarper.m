function warpedLatencies = fullVolumeWarper(data1, data2, fs, windowSizes, baseline)
% defines window and then steps through dtw for each electrode and window
% assumes data1 is in the same order as data 2, i.e. data1(1) is the same participant as data2(1)

% check if windowSize is passed in, if not iterate over multiple lengths
if nargin < 4
    sigSize = length(data1{1}.time)/fs;
    windowSizes = round([sigSize/10, sigSize/5,sigSize/3,sigSize/2] * fs); %100ms window
    baseline = 100;
end

n_participants = length(data1);
n_electrodes = length(data1{1}.label);
signalLength = length(data1{1}.time);

%quick error check
if n_participants ~= length(data2)
    error('data1 and data2 must have the same number of participants')
end

warped_paths = data1; %we replave the .avg field with the warped latencies

% for each participant
parfor i = 1:n_participants
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
                [maxlatmedian, ~, ~] = dynamictimewarper(data2_window, data1_window, fs);
                
                temp_warped(k) = maxlatmedian;
                
            end
            
            % Store the warped latencies for this window size
            warped_latencies_all_windows(j, :, l) = temp_warped;
        end
    end
    
    % Compute the mean across the different window sizes
    mean_warped_all_windows = mean(warped_latencies_all_windows, 3);
    
    % Assign the mean values to the participant's warped paths
    warped_participant.avg = mean_warped_all_windows;
    warped_paths{i} = warped_participant;
end

warpedLatencies = warped_paths;

end