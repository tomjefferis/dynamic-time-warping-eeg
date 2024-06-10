function [data1,data2] = fullVolumeData(n_participants,length,fs,offset)
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\external\eeglab\');

config = struct('n', n_participants, 'srate', fs, 'length', length*fs);

leadfield = lf_generate_fromnyhead('montage', 'S64');

sourcelocs = lf_get_source_spaced(leadfield, 6, 25);

comp1 = {};
comp2 = {};


erp = struct();
erp.peakAmplitude = [3,-6,3,-2,7];
erp.peakLatency = [200,270,320,360,650];
erp.peakWidth = [65,70,56,55,600];
erp.peakAmplitudeDv = [0.2,0.2,0.2,0.2,0.2];
erp.peakLatencyDv = [10,10,10,10,10];
erp.probability = 1;
erp.type = 'erp';
erp.probabilitySlope = 0;
erp = utl_check_class(erp);

for i = 1:5
    erpTemp = struct();
    erpTemp.peakAmplitude = erp.peakAmplitude(i);
    erpTemp.peakLatency = erp.peakLatency(i);
    erpTemp.peakWidth = erp.peakWidth(i);
    erpTemp.peakAmplitudeDv = erp.peakAmplitudeDv(i);
    erpTemp.peakLatencyDv = erp.peakLatencyDv(i);
    erpTemp.probability = erp.probability;
    erpTemp.type = erp.type;
    erpTemp.probabilitySlope = erp.probabilitySlope;
    erpTemp = utl_check_class(erpTemp);
    
    erp2Temp = erpTemp;
    if i == 5
        erp2Temp.peakLatency = erpTemp.peakLatency + offset*fs;
    end
    
    c = struct();
    c.orientation = utl_get_orientation_pseudoperpendicular(sourcelocs, leadfield);
    c.source = sourcelocs(i);      % obtained from the lead field, as above
    c.signal = {erpTemp};    % the signal to simulate
    
    c2 = c;
    c2.signal = {erp2Temp};
    
    comp1{end+1} = utl_check_component(c, leadfield);
    comp2{end+1}  = utl_check_component(c2, leadfield);
    
end

noise = struct( ...
    'type', 'noise', ...
    'color', 'pink', ...
    'amplitude', max(abs(erp.peakAmplitude))*0.4);
noise = utl_check_class(noise);

c = struct();
c.orientation = utl_get_orientation_pseudoperpendicular(sourcelocs, leadfield);
c.source = sourcelocs(6);
c.signal = {noise};    % the signal to simulate
c = utl_check_component(c, leadfield);

comp1{end+1} = c;
comp2{end+1} = c;



% simulating data
data = generate_scalpdata(cell2mat(comp1), leadfield, config);
data2 = generate_scalpdata(cell2mat(comp2), leadfield, config);

epochs.n = n_participants;
epochs.marker = 'event 1';
epochs.prestim = 100;
epochs.srate = fs;
epochs.length = 1000;

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

