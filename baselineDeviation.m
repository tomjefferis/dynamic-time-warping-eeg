function latency = baselineDeviation(data1,data2,fs,baseline, deviation)

    avgLatency = [];

    for i = 1:size(data1,1)

        dat1 = data1{i}.erp;
        dat2 = data2{i}.erp;

        dat1_base = dat1(1:baseline);
        dat2_base = dat2(1:baseline);

        dat1_dev = std(dat1_base);
        dat2_dev = std(dat2_base);

        threshold1 = dat1_dev*deviation;
        threshold2 = dat2_dev*deviation;

        latency1 = length(dat1);
        latency2 = length(dat2);

        % find the first point that data crosses the threshold and use this as index for latency
        for j = 1:length(dat1)
            if dat1(j) > mean(dat1_base)+ threshold1
                latency1 = j;
                break
            end
        end

        for j = 1:length(dat2)
            if dat2(j) > mean(dat2_base)+ threshold2
                latency2 = j;
                break
            end
        end
        fs = 1/fs;
        lat = latency1 - latency2;
        avgLatency(i) = lat*fs;

    end

    latency = mean(avgLatency);


end