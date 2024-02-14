function latency = peakArea(data1, data2, fs, areaThreshold, baseline)

    % determines the latency using fractional area
    avgLatency = [];

    %first we need to determine the point at which the area is calcualted from, suggested not from 0 because of noise 
    %we will use the point at which the signal is 5% of the max - for this example 


    for i = 1:size(data1,1)
        dat1 = data1.erp;
        dat2 = data2.erp;


        dat1_base = dat1(1:round(baseline));
        dat2_base = dat2(1:round(baseline));

        dat1_base_std = std(dat1_base);
        dat2_base_std = std(dat2_base);

        dat1_base_mean = mean(dat1_base);
        dat2_base_mean = mean(dat2_base);


        component_start_1 = find(dat1 > dat1_base_mean + 2*dat1_base_std, 1, 'first');
        try
            component_end_1 = find(dat1 >= dat1(component_start_1), 1, 'last');
        catch 
            try
                component_start_1 = baseline;
                component_end_1 = find(dat1 >= dat1(component_start_1), 1, 'last');
             catch 
                component_start_1 = baseline;
                component_end_1 = dat1(end);
            end
        end

        component_start_2 = find(dat2 > dat2_base_mean + 2*dat2_base_std, 1, 'first');
        try
            component_end_2 = find(dat2 >= dat2(component_start_2), 1, 'last');
        catch 
            try
            component_start_2 = baseline;
            component_end_2 = find(dat2 >= dat2(component_start_2), 1, 'last');
            catch 
                component_start_2 = baseline;
                component_end_2 = dat2(end);
            end
        end



        %calculate the area under the curve from the threshold to the max point

        maxArea1 = trapz(dat1(component_start_1:component_end_1));
        maxArea2 = trapz(dat2(component_start_2:component_end_2));



        %figure;
        %plot(dat1,'linewidth',2);
        %hold on;
        %xline(component_start_1,"LineWidth", 1.5);
        %xline(component_end_1,"LineWidth", 1.5);
        %yline(dat1(component_start_1));
        % fill the area under the curve and above the threshold
        %fill([component_start_1:component_end_1], dat1(component_start_1:component_end_1), 'r', 'FaceAlpha', 0.6);
        

        % calculate the point at which the area is 50% of the max area 
        areaThresh1 = maxArea1*areaThreshold;
        areaThresh2 = maxArea2*areaThreshold;

        % find the point at which the area is 50% of the max area
        areaIndex1 = find(cumtrapz(dat1(component_start_1:component_end_1)) >= areaThresh1, 1, 'first') + component_start_1;
        areaIndex2 = find(cumtrapz(dat2(component_start_2:component_end_2)) >= areaThresh2, 1, 'first') + component_start_2;

        %xline(areaIndex1, "LineWidth", 2, "Color", "b");
        % fill the 50% area
        %fill([component_start_1:areaIndex1], dat1(component_start_1:areaIndex1), 'b', 'FaceAlpha', 0.6);

        if isempty(areaIndex2)
            areaIndex2 = length(dat2);
        end

        if isempty(areaIndex1)
            areaIndex1 = length(dat1);
        end

        % calculate the latency
        latency = (areaIndex1 - areaIndex2);
        f = 1/fs;
        
        avgLatency(i) = latency*f;
        


    end

    latency = mean(avgLatency);
end

