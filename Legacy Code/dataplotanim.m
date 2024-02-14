%% file is for generateing animation for the simulation data
clear all;
restoredefaultpath;
addpath funcs/;
addpath generate_signals/;
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
if ~contains(path,'W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
end

%% load data config
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds
signalLens = [0.6 :0.01: 1.5]; % signal lengths to test in seconds
latencydiff = 0.05; % latency difference between two signals in seconds
fs = 1000; % sampling frequency in Hz
SNR = 0.8; % signal to noise ratio

frames = {};



for i = 1:length(signalLens)
    signalLen = signalLens(i);
    
    if (baseline > signalLen/4)
        baselineFun = signalLen*0.1;
    else
        baselineFun = baseline;
    end
    
    signalLen = signalLen - baselineFun;
    [sig1, sig2] = ERPGenerate(signalLen, fs, variance, SNR, baseline, latencydiff);
    
    [sig1s] = zscore(ft_preproc_bandpassfilter(sig1{1}.erp',fs,[1 30]));
    [sig2s] = zscore(ft_preproc_bandpassfilter(sig2{1}.erp',fs,[1 30]));

    [~,ix,iy] = dtw(sig1s',sig2s');
    
    sig1{1}.erp = sig1s;
    sig2{1}.erp = sig2s;
    
    
    % dtw signal
    [~, ix, iy] = dtw(zscore(sig1{1}.erp), zscore(sig2{1}.erp));
    
    time = [0:1/fs:signalLens(end-1)];
    sigtime = [0:1/fs:length(sig1{1}.erp)/fs];
    % remove last item
    sigtime = sigtime(1:end-1);
    
    %% plot frame for animation
    figure('Position', [0, 0, 1900, 1200]);
    hold on;
    for m = 1:length(ix)
        plot([ix(m), iy(m)], [sig1{1}.erp(ix(m)), sig2{1}.erp(iy(m))], 'k--', 'LineWidth', 0.5, 'Color', [0.8,0.8,0.8]);
    end
    
    plot(sig1{1}.erp, "LineWidth", 2, "Color", 'r');
    plot(sig2{1}.erp, "LineWidth", 2, "Color", 'b');
    xline(baselineFun, "LineWidth", 1, "Color", 'r', "LineStyle", "--", "Alpha", 0.5);
    % plot dtw
    
    % Create inset figure for histogram
    
    
    
    
    
    tit = strcat("ERP Signals with ",string(latencydiff),"s latency difference");
    title(tit);
    xlabel("Timepoints");
    ylabel("Amplitude");
    set(gca, "FontSize", 14);
    set(gcf, "Color", "w");
    %xlim([0, signalLens(end)]);
    ylim([-5, 5]);
    grid on;
    hold off;
    insetPos = [0.7, 0.2, 0.2, 0.2]; % Position of the inset figure [left, bottom, width, height]
    insetAx = axes('Position', insetPos);
    histogram(ix - iy);
    title('Distribution of Distances');
    xlabel('Timepoints Latency');
    ylabel('Frequency');
    hold on;
    xline(latencydiff*fs, "Color", 'r', 'LineWidth',1.5)
    xline(median(ix-iy),"Color", 'g', 'LineWidth',1.5)
    
    
    
    %% save frame
    frames{end+1} = frame2im(getframe(gcf));
    
end
close all;

% save images as video
videoName = 'animation.mp4';
frameRate = 10; % frames per second

% Create a VideoWriter object
video = VideoWriter(videoName, 'MPEG-4');
video.FrameRate = frameRate;
video.Quality = 95;

% Open the VideoWriter object
open(video);

% Write each frame to the video
for i = 1:length(frames)
    writeVideo(video, frames{i});
end

% Close the VideoWriter object
close(video);

