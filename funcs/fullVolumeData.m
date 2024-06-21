function [data1,data2] = fullVolumeData(n_participants,length,fs,offset)
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\external\eeglab\');

config = struct('n', n_participants, 'srate', fs, 'length', length*fs, 'useParallelPool',0);

leadfield = lf_generate_fromnyhead('montage', 'S64');
randCompNum = 20;
sourcelocs = [[0 -100 -15]; [0 -90 -10]; [0 -85 0]; [0 -70 10]; [0 -50 80]; [0 0 0]];

comp1 = {};
comp2 = {};


erp = struct();
erp.peakAmplitude = [2,-3,1,-1,3];
erp.peakLatency = [230,290,350,390,650];
erp.peakWidth = [65,70,56,55,600];
erp.peakAmplitudeDv = [0.5,0.5,0.5,0.5,0.0];
erp.peakLatencyDv = [20,20,20,20,0];
erp.probability = 1;
erp.type = 'erp';
erp.probabilitySlope = 0;
erp = utl_check_class(erp);

sourceStruc = [];

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
    c.source = lf_get_source_nearest(leadfield, sourcelocs(i,:)); 
    c.orientation = utl_get_orientation_pseudoperpendicular(c.source, leadfield);
    sourceStruc{i} = c.source;
    c.signal = {erpTemp};    % the signal to simulate
    
    c2 = c;
    c2.signal = {erp2Temp};
    
    comp1{end+1} = utl_check_component(c, leadfield);
    comp2{end+1}  = utl_check_component(c2, leadfield);
    
end

noise = struct( ...
    'type', 'noise', ...
    'color', 'pink', ...
    'amplitude', max(abs(erp.peakAmplitude))*0.1);
noise = utl_check_class(noise);

c = struct();
c.source = lf_get_source_nearest(leadfield, sourcelocs(6,:));
c.orientation = utl_get_orientation_pseudoperpendicular(c.source, leadfield);
c.signal = {noise};    % the signal to simulate
c = utl_check_component(c, leadfield);

comp1{end+1} = c;
comp2{end+1} = c;

randComps = erp_get_class_random([1:3], [200:1000], [25:200], ...
		[-0.5:.1:0.5], 'numClasses', randCompNum);
randSource = lf_get_source_random(leadfield,randCompNum);
c = utl_create_component(randSource, randComps, leadfield);

comp1 = cell2mat(comp1);
comp1 = orderfields(comp1, [1,3,2,4]);
comp1 = [comp1, c];

randComps = erp_get_class_random([1:3], [200:1000], [25:200], ...
		[-0.5:.1:0.5], 'numClasses', randCompNum);
randSource = lf_get_source_random(leadfield,randCompNum);
c = utl_create_component(randSource, randComps, leadfield);

comp2 = cell2mat(comp2);
comp2 = orderfields(comp2, [1,3,2,4]);
comp2 = [comp2 c];

% simulating data
data = generate_scalpdata(comp1, leadfield, config,'sensorNoise',max(abs(erp.peakAmplitude))*0.001,'useParallelPool',0);
data2 = generate_scalpdata(comp2, leadfield, config,'sensorNoise',max(abs(erp.peakAmplitude))*0.001,'useParallelPool',0);

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
    cfg.demean = 'yes';
    cfg.reref = 'yes';
    cfg.refchannel = 'all';
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

