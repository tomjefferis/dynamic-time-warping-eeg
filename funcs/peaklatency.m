function latency = peaklatency(data1, data2, fs)

    for i = 1:size(data1,1)
        % get the peak of data1 and data2 with the indexs using max
        [pks1,locs1] = max(abs(data1.erp));
        [pks2,locs2] = max(abs(data2.erp));

        loc1(i) = locs1;
        loc2(i) = locs2;

    end

    loc1 = mean(loc1);
    loc2 = mean(loc2);

    f = 1/fs;
    latency = (loc1 - loc2) * f;
    
end

