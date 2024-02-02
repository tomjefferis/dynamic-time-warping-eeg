function [maxlatmedian, maxlat, maxlat95] = dynamictimewarper(data1, data2, fs)
% Dynamic Time Warper is a function that gets the DTW distance for the
% electrode and computes the Fractional peak, peak, and area of the erp
% component

% Input: data = array of erp data for a single electrode samples x trials

% check if W:\PhD\MatlabPlugins\fieldtrip-20210906 is in the path
if ~contains(path,'W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
end


for i = 1:size(data1,2)

    [query] = zscore(ft_preproc_bandpassfilter(data1{i}.erp',fs,[1 30]));
    [reference] = zscore(ft_preproc_bandpassfilter(data2{i}.erp',fs,[1 30]));

    [~,ix,iy] = dtw(query',reference');
    latency = ix - iy; % doing x - y since if the horizontal distance was 0 that would mean x=y 
    meanAbsLatency{i} = latency;
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
[~, maxlatmedian] = min(abs(abs(lat) - maxlatmedian));
maxlatmedian = lat(maxlatmedian);
maxlatmedian = maxlatmedian*fs;


% weighted median using zscores of each point on dtw path
weightedLats = [];
% for every point on the warping path
for i = 1:length(ix)
    % avgZscore = rounded abs zscores for each point in original signal
    % from correlating warping path
    avgZscore = round(mean(abs(query(ix(i))) + abs(reference(iy(i)))));
    % add that latency into the distrubution avgZscore times
    for j = 1:avgZscore
        weightedLats = [weightedLats;lat(i)];
    end
end
    % get the median from this array
    medianWeightedLat= median(weightedLats);
    % find the closest actual latency in the warping path
    [~, maxWeightedlatmedian] = min(abs(abs(lat) - medianWeightedLat));
    maxWeightedlatmedian = lat(maxWeightedlatmedian);
    % turn into seconds
    maxlat = maxWeightedlatmedian*fs;


% 95th percentile of absolute latency
maxlat95 = prctile(abs(lat),95);
% find the index of the closest value to the 95th percentile
[~, maxlat95] = min(abs(abs(lat) - maxlat95));
% get the value of the 95th percentile
maxlat95 = lat(maxlat95);
maxlat95 = maxlat95*fs;

end

