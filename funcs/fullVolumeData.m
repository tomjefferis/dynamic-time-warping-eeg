function [data1,data2] = fullVolumeData(n_participants,length,fs,offset)
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\external\eeglab\');

config = struct('n', n_participants, 'srate', fs, 'length', length*fs);

leadfield = lf_generate_fromnyhead('montage', 'S64');

sourcelocs = lf_get_source_spaced(leadfield, 1, 25);

erp = struct();
erp.peakAmplitude = [3,-6,3,-2,7];
erp.peakLatency = [200,270,320,360,650];
erp.peakWidth = [65,70,56,55,600];
erp.peakLatencyDv = [0.2,0.2,0.2,0.2,0.2];
erp.peakLatencyDv = [10,10,10,10,10];
erp.probability = 1;
erp.type = 'erp';
erp.probabilitySlope = 0;
erp = utl_check_class(erp);

erp2 = erp;
erp2.peakLatency(5) = erp2.peakLatency(5)+ offset*fs;
erp2 = utl_check_class(erp2);

noise = struct( ...
    'type', 'noise', ...
    'color', 'pink', ...
    'amplitude', max(abs(erp.peakAmplitude))*0.2);
noise = utl_check_class(noise);

c = struct();
c.source = sourcelocs;      % obtained from the lead field, as above
c.signal = {erp, noise};    % the signal to simulate

c2 = c;
c2.signal = {erp2, noise};

c = utl_check_component(c, leadfield);
c2 = utl_check_component(c2, leadfield);

config.useParallelPool = 0;

% simulating data
data = generate_scalpdata(c, leadfield, config);
data2 = generate_scalpdata(c2, leadfield, config);

epochs.n = n_participants;
epochs.marker = 'event 1';  
epochs.prestim = 100;
epochs.srate = fs;

EEG = utl_create_eeglabdataset(data, epochs, leadfield);
EEG2 = utl_create_eeglabdataset(data2, epochs, leadfield);

% convert to fieldtrip
ftdata = [];
for i = 1:(epochs.n)*2

    if i > n_participants
        tempeeg = EEG2;
        j = i - n_participants;
    else
        tempeeg = EEG;
        j = i;
    end
    tempeeg.trials = 1;

    tempeeg.data = tempeeg.data(:,:,j);
    tempeeg.epoch = tempeeg.epoch(j);

    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfilttype = 'but';
    cfg.bpfreq = [1 30];
    cfg.baselinewindow = [-0.1 0];

    tempeeg = ft_preprocessing(cfg,eeglab2fieldtrip(tempeeg,'raw','none'));

    % timelock analysis
    cfg = [];
    cfg.covariance = 'no';
    cfg.keeptrials = 'no';

    ftdata{i} = ft_timelockanalysis(cfg,tempeeg);

end

data1 = ftdata(1:n_participants);
data2 = ftdata(n_participants+1:end);

end

