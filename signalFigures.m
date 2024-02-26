addpath(genpath('SEREEGA-master\')) 
addpath(genpath('W:\PhD\MatlabPlugins\fieldtrip-20210906')); % path to fieldtrip
addpath funcs\



n_components = 1:8;
sig_length = 1; 
fs = 1000;
component_widths = 25:250;
min_amplitude = -10;
max_amplitude = 10; 
SNR = 0.3;
latency_diff = 0.05; 

% subplot 8x1 
figure();
axs = [];
for i = n_components

    component_range = round(sig_length*fs*0.3) : round(sig_length*fs*0.8);

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
legend('Signal 1', 'Signal 2')
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
title('Latency difference signal 1 and 2, no noise')


set(gcf, 'Position', [0, 0, 720, 480]);

saveas(gcf, 'Results\signal_with_latency_diff.png')
