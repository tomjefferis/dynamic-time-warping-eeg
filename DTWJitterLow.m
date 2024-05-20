function [ERP1,baseSignal,grandAVG,jitters] = DTWJitterLow(jitter,siglen,fs,trials,component_amplitude,component_widths,snr,n_components)

    siglen = siglen*fs;
    erp = [];
    erp = erp_get_class_random(n_components, round(siglen*0.2) : round(siglen*0.8), component_widths, component_amplitude,'numClasses', 1);
    epochs = struct();
    epochs.n = trials;             % the number of epochs to simulate
    epochs.srate = fs;        % their sampling rate in Hz
    epochs.length = siglen;       % their length in ms
    baseSignal = generate_signal_fromclass(erp, epochs);

    latencies = erp.peakLatency;

    %erp.peakLatencyShift = jitter*fs;
    ERP1 = [];
    jitters = [];

    for i = 1:trials
        epochs = struct();
        epochs.n = trials;             % the number of epochs to simulate
        epochs.srate = fs;        % their sampling rate in Hz
        epochs.length = siglen;       % their length in ms
        epochs.epochNumber = i;

         
        jitter_amount = randi([-jitter*fs, jitter*fs]);
        jitters = [jitters jitter_amount];
        erp.peakLatency = latencies + jitter_amount;

        ERP = generate_signal_fromclass(erp, epochs);
        noise = struct( ...
                    'type', 'noise', ...
                    'color', 'pink', ...
                    'amplitude', max(component_amplitude)*snr);
            noise = utl_check_class(noise);

            noise = generate_signal_fromclass(noise, epochs);

        ERP1(i,:) = ERP + noise;

    end

    grandAVG = mean(ERP1,1);


    
end