addpath funcs\;
addpath 'Legacy Code'\generate_signals\;
addpath 'Legacy Code'
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
if ~contains(path,'W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
end


variance = 0.04; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds
signalLen = 2.5; % signal lengths to test in seconds
latencydiff = 0.1; % latency difference between two signals in seconds
fs = 1000; % sampling frequency in Hz
SNR = 0.93; % signal to noise ratio

[sig1, sig2] = ERPGenerate(signalLen, fs, variance, SNR, baseline, latencydiff);

[sig1s] = zscore(ft_preproc_bandpassfilter(sig1{1}.erp',fs,[1 30]));
[sig2s] = zscore(ft_preproc_bandpassfilter(sig2{1}.erp',fs,[1 30]));

sig1{1}.erp = sig1s;
sig2{1}.erp = sig2s;


[~,ix,iy] = dtw(sig1{1}.erp',sig2{1}.erp');


%  subplots 1 x 2, left plot is the two signals and the right is hitsogram

figure;
subplot(1,3,1);
plot(sig1{1}.erp,'r','LineWidth',1.5);
hold on;
plot(sig2{1}.erp,'b','LineWidth',1.5);
hold off;
legend('Signal 1','Signal 2','Location','southoutside');
xlabel('Time (s)');
ylabel('Amplitude (Z score)');
title('ERP Signals with 100 timepoint latency difference');


subplot(1,3,2);
histogram(ix-iy);
xlabel('Timepoints');
ylabel('Frequency');
title('Histogram of Time Differences');
% plot median 
hold on;
xline(median(ix-iy) ,'Color','r','LineWidth',1.5);
% plot 95th percentile
xline(prctile(ix-iy,95),'Color','g','LineWidth',1.5);
% actual latency difference
xline(latencydiff*fs,'Color','b','LineWidth',1.5);

legend('Time Differences','Median','95th Percentile','Actual Latency Difference','Location','southoutside');

query = sig1{1}.erp';
reference = sig2{1}.erp';
lat = ix - iy;
% weighted median using zscores of each point on dtw path
weightedLats = [];
% for every point on the warping path
for i = 1:length(ix)
    % avgZscore = rounded abs zscores for each point in original signal
    % from correlating warping path
    avgZscore = round(mean(abs(query(ix(i))) + abs(reference(iy(i)))));
    if avgZscore <= 0 
        avgZscore = 1;
    end
    % add that latency into the distrubution avgZscore times
    for j = 1:avgZscore
        weightedLats = [weightedLats;lat(i)];
    end
end

subplot(1,3,3);
histogram(weightedLats);
xlabel('Time (s)');
ylabel('Frequency');
title('Histogram of Z Score Weighted Time Differences');
% plot median
hold on;
xline(median(weightedLats) ,'Color','r','LineWidth',1.5);
% actual latency difference
xline(latencydiff*fs,'Color','b','LineWidth',1.5);

% legend below plot
legend('Time Differences','Median','Actual Latency Difference','Location','southoutside');
