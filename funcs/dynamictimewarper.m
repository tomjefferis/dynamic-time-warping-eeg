function [maxlatmedian, maxlat, maxlat95] = dynamictimewarper(data1, data2, fs)
% Dynamic Time Warper is a function that gets the DTW distance for the
% electrode and computes the Fractional peak, peak, and area of the erp
% component

% Input: data = array of erp data for a single electrode samples x trials


for i = 1:size(data1,2)
    query = zscore(data1{i}.erp);
    reference = zscore(data2{i}.erp);
    [dist,ix,iy] = dtw(query,reference);
    latency = ix - iy; % doing x - y since if the horizontal distance was 0 that would mean x=y 
    meanAbsLatency{i} = latency;
    %% create a 3x3 subplot of the warping path, and the two signals
    %subplot(3,3,[1 4])
    %plot(query)
    %view([-90 90])
    %title("Query Signal")
    %subplot(3,3,[8 9])
    %plot(reference)
    %title("Reference Signal")
    %subplot(3,3,[2 3 5 6])
    %plot(ix,iy,'--',[ix(1) ix(end)],[iy(1) iy(end)])
    %title("Warping Path")
    %xlabel("Reference Signal")
    %ylabel("Query Signal")
    % make plot 1080x1080 pixels
    %set(gcf,'Position',[0 0 1080 1080])
    %arealatency(i) = (trapz(ix,iy) - trapz([ix(1) ix(end)],[iy(1) iy(end)]))/trapz([ix(1) ix(end)],[iy(1) iy(end)]);
end

fs = 1/fs;
lat = zeros(size(meanAbsLatency,2),max(cellfun('size',meanAbsLatency,2)));
lat(lat==0) = NaN;
for i = 1:size(meanAbsLatency,2)
    lat(i,1:size(meanAbsLatency{i},2)) = meanAbsLatency{i};
end

pathlength = length(ix)*fs;


% find iqr of absolute latency
maxlatmedian = median(lat);
% maybe use iqr to exclude outliers 
% find the index of the closest value to the 95th percentile
[~, maxlatmedian] = min(abs(abs(lat) - maxlatmedian));
% get the value of the 95th percentile
maxlatmedian = lat(maxlatmedian);
maxlatmedian = maxlatmedian*fs;


[~, maxlatIDX] = max(abs(lat));
maxlat = lat(maxlatIDX);
maxlat = maxlat*fs;

% 95th percentile of absolute latency
maxlat95 = prctile(abs(lat),95);
% find the index of the closest value to the 95th percentile
[~, maxlat95] = min(abs(abs(lat) - maxlat95));
% get the value of the 95th percentile
maxlat95 = lat(maxlat95);
maxlat95 = maxlat95*fs;

end

