addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\



n_components = 1:8;
sig_length = 1; 
fs = 1000;
component_widths = 25:250;
min_amplitude = -10;
max_amplitude = 10; 
SNR = 0.5;
latency_diff = 0.05; 

% subplot 8x1 
figure();
axs = [];
for i = n_components

    component_range = round(sig_length*fs*0.2) : round(sig_length*fs*0.8);

    amps = [min_amplitude:.1:min_amplitude/2, max_amplitude/2:.1:max_amplitude];

    erp = erp_get_class_random(i, component_range, component_widths, amps,'numClasses', 1);

    epochs = struct();
    epochs.n = 1;          
    epochs.srate = fs;        
    epochs.length = sig_length*fs; 
    dat1 = generate_signal_fromclass(erp, epochs);


    if i == 6
        dat6 = dat1;
        erp2 = erp;
        erp2.peakLatency = erp2.peakLatency + latency_diff*fs;  
        dat2 = generate_signal_fromclass(erp2, epochs);
    end

    ax1 = subplot(8,1,i);
    plot(dat1, "LineWidth", 1.5)
    xlabel('Time (ms)')
    ylabel('Amplitude (uV)')
    %title on left side
    title(['N components: ' num2str(i)])
    ax1.TitleHorizontalAlignment = 'left';
    ylim([-15 15])

    axs = [axs, ax1];

end

linkaxes(axs, 'xy')
ylim([-20 20])

sgtitle('Randomly generated signals with increasing number of components')
set(gcf, 'Position', [0, 0, 1920/3, 1080]);

saveas(gcf, 'Results\random_signals_n_components.png')


noise = struct( ...
                    'type', 'noise', ...
                    'color', 'pink', ...
                    'amplitude', max(abs(min_amplitude),abs(max_amplitude))*SNR);
noise = utl_check_class(noise);
noise = generate_signal_fromclass(noise, epochs);

figure();

plot(noise, "LineWidth", 1.5)
xlabel('Time (ms)')
ylabel('Amplitude (uV)')

title('Pink noise')
ylim([-20*0.2 20*0.2])
set(gcf, 'Position', [0, 0, 720, 480]);

saveas(gcf, 'Results\pink_noise.png')



data = dat1 + noise;

figure();

plot(data, "LineWidth", 1.5)
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
title('8 component signal with pink noise')
ylim([-20 20])

set(gcf, 'Position', [0, 0, 720, 480]);

saveas(gcf, 'Results\signal_with_pink_noise.png')


data = ft_preproc_bandpassfilter(data,fs,[1 30]);

figure();

plot(data, "LineWidth", 1.5)
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
title('8 component signal with pink noise after bandpass filter')
ylim([-20 20])

set(gcf, 'Position', [0, 0, 720, 480]);

saveas(gcf, 'Results\signal_with_pink_noise_filtered.png')



figure();

plot(dat6, "LineWidth", 1.5)
hold on
plot(dat2, "LineWidth", 1.5)
%legend('Signal 1', 'Signal 2')
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
title('Latency difference signal 1 and 2, no noise')


set(gcf, 'Position', [0, 0, 720, 480]);

saveas(gcf, 'Results\signal_with_latency_diff.png')

fs = 500;
erp = struct();
erp.peakAmplitude = [3,-6,3,-2,7];
erp.peakLatency = [100,135,170,180,325];
erp.peakWidth = [33,35,27,26,300];
erp.probability = 1;
erp.type = 'erp';
erp.probabilitySlope = 0;
erp = utl_check_class(erp);

epochs = struct();
epochs.n = 1;             % the number of epochs to simulate
epochs.srate = fs;        % their sampling rate in Hz
epochs.length = fs;       % their length in ms

noise = struct( ...
    'type', 'noise', ...
    'color', 'pink', ...
    'amplitude', max(abs(erp.peakAmplitude))*0.3);
noise = utl_check_class(noise);

sig1 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);

erp.peakLatency(5) = erp.peakLatency(5) + latency_diff*fs;

sig2 = generate_signal_fromclass(erp, epochs) + generate_signal_fromclass(noise, epochs);

data = struct();
data.erp = ft_preproc_bandpassfilter(sig1,fs,[1 30]);
data2 = struct();
data2.erp = ft_preproc_bandpassfilter(sig2,fs,[1 30]);

% get baselines
baselinePeriod = [-0.1,0];
time = -0.1:1/fs:sig_length-0.1;
time = time(1:end-1);
cfg = [];
cfg.baseline = baselinePeriod;
cfg.parameter = 'erp';
data.time = time;
data2.time = time;
data.dimord = 'chan_time';
data2.dimord = 'chan_time';
data.label = {'A23'};
data2.label = {'A23'};

data = ft_timelockbaseline(cfg, data);
data2 = ft_timelockbaseline(cfg, data2);

data.erp = data.erp';
data2.erp = data2.erp';


% plot 3x1, first plot is signal1 and signal2, second plot is the DTW warping path and third plot is the distribution of the warping path

figure();
subplot(2,3,[1,2,4,5])
[distance,ix,iy] = dtw(data.erp, data2.erp);
% plot matching points as dotted  grey lines with 50% alpha
plot(data.erp, "LineWidth", 1.5)
hold on
plot(data2.erp, "LineWidth", 1.5)
for i = 1:length(ix)
    plot([ix(i), iy(i)], [data.erp(ix(i)), data2.erp(iy(i))], 'Color', [0.5,0.5,0.5,0.5], 'LineStyle', '--')
end
legend('Signal 1', 'Signal 2')
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
title('Signal 1 and 2 with latency difference')

subplot(2,3,6)
plot(ix, iy, 'LineWidth', 1.5)
xlabel('Time (ms)')
ylabel('Time (ms)')
title('DTW warping path')
% dashed going from top left to bottom right
hold on
plot([1, ix(end)], [1, iy(end)], 'Color', [0.5,0.5,0.5], 'LineStyle', '--')

subplot(2,3,3)
histogram(ix - iy, 'Normalization', 'probability')
xlabel('Time difference (ms)')
ylabel('Probability')
title('Distribution of warping path')
sgtitle("DTW example between two signals with offset P3 component");

% set plot size to 1920x720
set(gcf, 'Position', [0, 0, 1280, 480]);
saveas(gcf, 'Results\dtw_example.png')