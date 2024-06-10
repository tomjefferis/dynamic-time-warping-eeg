function warped_participant = fullVolumeWarperLow()
        windowSize = windowSizes(i);
    % for each electrode
    warped_participant = warped_paths{i};
    for j = 1:n_electrodes
        % get the data for the current electrode
        data1_temp = data1{i};
        data2_temp = data2{i};
        
        data1_erp = zscore(data1_temp.avg(j,:));
        data2_erp = zscore(data2_temp.avg(j,:));
        
        temp_warped = zeros(1,signalLength);
        
        for k = 1:signalLength
            
            % k is the index of the signal we are looking at
            % want to use K as the center of the window and zero pad if this window goes out of bounds
            if k - windowSize < 1
                % Case 1: Window goes out of bounds on the left side
                pad_left = abs(k - windowSize - 1);
                data1_window = [zeros(1, pad_left), data1_erp(1:k+windowSize)];
                data2_window = [zeros(1, pad_left), data2_erp(1:k+windowSize)];
            elseif k + windowSize > signalLength
                % Case 2: Window goes out of bounds on the right side
                pad_right = k + windowSize - signalLength;
                data1_window = [data1_erp(k-windowSize:end), zeros(1, pad_right)];
                data2_window = [data2_erp(k-windowSize:end), zeros(1, pad_right)];
            else
                % Case 3: Window is within bounds
                data1_window = data1_erp(k-windowSize:k+windowSize);
                data2_window = data2_erp(k-windowSize:k+windowSize);
            end
            
            [maxlatmedian, ~, ~] = dynamictimewarper(data2_window, data1_window, fs);
            
            temp_warped(k) = maxlatmedian;
            
        end
        
        warped_participant.avg(j,:) = temp_warped;
    end
    warped_paths{i} = warped_participant;
end