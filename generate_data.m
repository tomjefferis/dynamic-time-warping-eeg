function signals = generate_data(desired_time, desired_fs, desired_noise_level, desired_trials, ...
    desired_participants, desired_jitter, desired_peak_fs, desired_peak_loc)
    %% add path to the generate signals script
    % https://data.mrc.ox.ac.uk/data-set/simulated-eeg-data-generator
    addpath generate_signals\



   
    desired_total_trials = desired_participants * desired_trials;
    desired_toi = [0, desired_time];

    n_samples = desired_time * desired_fs;
    peak_time = desired_peak_loc * desired_fs;


    my_noise = noise(n_samples, desired_total_trials, desired_fs);
    my_peak = peak(n_samples, desired_total_trials, desired_fs, desired_peak_fs, peak_time, desired_jitter);

    signal =  my_peak + (my_noise*desired_noise_level);

    if desired_total_trials > 1
        my_noise = split_vector(my_noise, n_samples);
        my_peak = split_vector(my_peak, n_samples);
    else
        my_noise = my_noise';
        my_peak = my_peak';
    end

    %% add the pink noise on top of the sythetic data
    signals = zeros(n_samples, desired_total_trials);
    for t = 1:desired_total_trials
        noise_j = my_noise(:,t);
        peak_j = my_peak(:,t);
        sig_w_pink_noise = peak_j + (noise_j*desired_noise_level);
        signals(:,t) = sig_w_pink_noise;
    end

    %% create synth participants and generate their ERPs
    make_plot = 1;
    participants = {};
    k_trials = desired_trials;
    for p = 1:desired_participants
        
        if p == 1
            subset = signals(:,1:k_trials);
        else
            subset = signals(:,k_trials+1:k_trials + (desired_trials));
            k_trials = k_trials + desired_trials;
        end
        
        %subset = bpfilt(subset, 0.1, 30, desired_fs, 0);
        erp = mean(subset,2);
        %erp  = bpfilt(erp, 0.1, 30, desired_fs, 0);
        %plot(erp);
        data.erp = erp;
        data.trials = subset;
        participants{p} = data;
        
        
    end
    signals = participants;
end

%% split vector
function v = split_vector(vector, n_samples)
    n_chunks = size(vector,2)/n_samples;

    curr_chunk = n_samples;
    v = zeros(n_samples, n_chunks);
    for chunk = 1:n_chunks
        if chunk == 1
            c = vector(1, 1:curr_chunk);
            curr_chunk = curr_chunk + n_samples;
        else
            c = vector(1, (curr_chunk-n_samples)+1: curr_chunk);
            curr_chunk = curr_chunk + n_samples;
        end

        c = c';
        v(:, chunk) = c(:,1);
        
    end
end

