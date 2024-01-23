%% file is for generateing animation for the simulation data
clear all;
restoredefaultpath;
addpath funcs/;
addpath generate_signals/;


%% load data config
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds
signalLens = [0.15 :0.01: 1]; % signal lengths to test in seconds
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
    ylim([-2.5, 2.5]);
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
%% file is for generateing animation for the simulation data
clear all;
restoredefaultpath;
addpath funcs/;
addpath generate_signals/;


%% load data config
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds
signalLens = [0.15 :0.01: 1]; % signal lengths to test in seconds
latencydiff = 0.05; % latency difference between two signals in seconds
fs = 1000; % sampling frequency in Hz
SNR = 0.2; % signal to noise ratio

frames = {};

for i = 1:length(signalLens)
    signalLen = signalLens(i);
    
    if (baseline > signalLen/4)
        baselineFun = signalLen*0.1;
    else
        baselineFun = baseline;
    end
    
    %signalLen = signalLen - baselineFun;
    
    desired_peak_loc_1 = rand(1)*(signalLen*0.5) + baselineFun;
    desired_peak_loc_2 = desired_peak_loc_1 - latencydiff;
    
    sig1 = generate_data(signalLen, fs, SNR, 1, ...
        1, 0, 10,desired_peak_loc_1);
    
    
    sig2 = generate_data(signalLen, fs, SNR, 1, ...
        1, 0, 10,desired_peak_loc_2);
    
    
    
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
    ylim([-2.5, 2.5]);
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
videoName = 'animation2.mp4';
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

%% file is for generateing animation for the simulation data
clear all;
restoredefaultpath;
addpath funcs/;
addpath generate_signals/;
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip

%% load data config
variance = 0.1; % variance of peaks in signal
baseline = 0.2; % baseline of signal in seconds
signalLens = [0.15 :0.03: 3]; % signal lengths to test in seconds
latencydiff = 0.05; % latency difference between two signals in seconds
fs = 1000; % sampling frequency in Hz
SNR = 0.2; % signal to noise ratio

frames = {};

load('grandavg.mat') % grand average for medium stimuli from pattern glare experiment

cfg = [];
cfg.baseline = [-0.5 0];
cfg.baselinetype = 'db';
cfg.parameter = 'avg';

grandavg = ft_timelockbaseline(cfg, x); % Gets Oz and baseline corrects
signal = grandavg.avg(23,:);
time = grandavg.time;
fs = 1/mean(diff(time));
signal1 = signal;
signal2 = [signal(round(latencydiff*fs):end), zeros(1,(length(signal)-length(signal(round(latencydiff*fs):end))))];


for i = 1:length(signalLens)
    signalLen = signalLens(i);
    
    if (baseline > signalLen/4)
        baselineFun = signalLen*0.1;
    else
        baselineFun = baseline;
    end
    noise1 = noise(length(signal1), 1, fs);
    noise2 = noise(length(signal2), 1, fs);
    
    signal1 = signal1 + noise1*SNR;
    signal2 = signal2 + noise2*SNR;
    
    %signalLen = signalLen - baselineFun;
    
    sig1{1}.erp = signal1(1:signalLen*fs);
    sig2{1}.erp = signal2(1:signalLen*fs);
    
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
    ylim([-8, 12.5]);
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
videoName = 'animation3.mp4';
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


