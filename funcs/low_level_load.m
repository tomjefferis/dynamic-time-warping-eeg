function [part1,part2,part3] = low_level_load(data)
    %% stores in struct of structs for each partition for reusability of onsets functions
    part1.label = data.label;
    part1.time = data.time{1};
    part1.trialinfo = [1];
    part1.elec = data.elec;
    part1.dimord = 'chan_time';
    part1.thin = data.p1_thin;
    part1.med = data.p1_med;
    part1.thick = data.p1_thick;

    if isfield(data, 'p1_pgi')
        part1.avg = data.p1_pgi;
    end

    part2.label = data.label;
    part2.time = data.time{1};
    part2.trialinfo = [1];
    part2.elec = data.elec;
    part2.dimord = 'chan_time';
    part2.thin = data.p2_thin;
    part2.med = data.p2_med;
    part2.thick = data.p2_thick;

    if isfield(data, 'p2_pgi')
        part2.avg = data.p2_pgi;
    end

    part3.label = data.label;
    part3.time = data.time{1};
    part3.trialinfo = [1];
    part3.elec = data.elec;
    part3.dimord = 'chan_time';
    part3.thin = data.p3_thin;
    part3.med = data.p3_med;
    part3.thick = data.p3_thick;

    if isfield(data, 'p3_pgi')
        part3.avg = data.p3_pgi;
    end
end