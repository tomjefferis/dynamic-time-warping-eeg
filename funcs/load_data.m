function [ft_data, order] = load_data(main_path, filename, n_participants, onsets_part)

    ft_data = {};
    idx_used_for_saving_data = 1;
    order = [];

    p1_data = {};
    p2_data = {};
    p3_data = {};

    on_23_p1 = {};
    on_23_p2 = {};
    on_23_p3 = {};
    on_45_p1 = {};
    on_45_p2 = {};
    on_45_p3 = {};
    on_67_p1 = {};
    on_67_p2 = {};
    on_67_p3 = {};

    % breaks up into 3 filenames for all onsets
    if strcmp(onsets_part, 'onsets-23-45-67') || strcmp(onsets_part, 'partitions-vs-onsets')
        a = string(filename);
        b = split(filename, '_');
        c = b(end);
        d = b(1:5);

        e = [d; {'2'; '3'}; c];
        f = [d; {'4'; '5'}; c];
        g = [d; {'6'; '7'}; c];

        filename = join(e, "_");
        filename2 = join(f, "_");
        filename3 = join(g, "_");
    end

    for index = 1:n_participants
        fprintf('LOADING %d/%d \n', index, n_participants);
        participant_main_path = strcat(main_path, int2str(index));

        if exist(participant_main_path, 'dir')
            cd(participant_main_path);

            if iscell(filename)
                filename = filename{1};
                filename2 = filename2{1};
                filename3 = filename3{1};
            end

            

            if strcmp(onsets_part, 'onsets') || strcmp(onsets_part, 'eyes')
                if isfile(filename)
                    load(filename);
                    order(end + 1) = index;
                else
                    continue;
                end
                ft.label = data.label;
                ft.time = data.time{1};
                ft.trialinfo = [1];
                ft.elec = data.elec;
                ft.dimord = 'chan_time';
                % removes crash when using single trials
                if ~iscell(data.med)
                    pgi = data.med - (data.thin + data.thick) / 2;
                    ft.avg = pgi;
                else
                    data.med = data.med(2:end);
                    data.thin = data.thin(2:end);
                    data.thick = data.thick(2:end);
                    pgi = {};
                    mindat = min([length(data.med), length(data.thin), length(data.thick)]);

                    for i = 1:mindat
                        pgi{i} = data.med{i} - (data.thin{i} + data.thick{i}) / 2;
                    end

                    ft.avg = pgi;
                end

                ft.thin = data.thin;
                ft.med = data.med;
                ft.thick = data.thick;

                ft_data{idx_used_for_saving_data} = ft;
                ft = {};
            elseif strcmp(onsets_part, 'partition1')

                ft.label = data.label;
                ft.time = data.time{1};
                ft.trialinfo = [1];
                ft.elec = data.elec;
                ft.dimord = 'chan_time';
                ft.thin = data.p1_thin;
                ft.med = data.p1_med;
                ft.thick = data.p1_thick;
                ft.avg = data.p1_pgi;

                ft_data{idx_used_for_saving_data} = ft;
            elseif strcmp(onsets_part, 'partitions-vs-onsets') 

                if isfile(filename) && isfile(filename2) && isfile(filename3)
                    load(filename);
                    data2 = load(filename2).data;
                    data3 = load(filename3).data;
                    order(end + 1) = index;
                else
                    continue;
                end
                
                [on_23_part1,on_23_part2,on_23_part3]  = low_level_load(data);
                [on_45_part1,on_45_part2,on_45_part3]  = low_level_load(data2);
                [on_67_part1,on_67_part2,on_67_part3]  = low_level_load(data3);

                

               
                    on_23_p1{end + 1} = on_23_part1;
                    on_23_p2{end + 1} = on_23_part2;
                    on_23_p3{end + 1} = on_23_part3;
                    on_45_p1{end + 1} = on_45_part1;
                    on_45_p2{end + 1} = on_45_part2;
                    on_45_p3{end + 1} = on_45_part3;
                    on_67_p1{end + 1} = on_67_part1;
                    on_67_p2{end + 1} = on_67_part2;
                    on_67_p3{end + 1} = on_67_part3;
                    
               


                


            elseif strcmp(onsets_part, 'partitions')
                if isfile(filename) 
                    load(filename);
                    order(end + 1) = index;
                else
                    continue;
                end
                
                [part1,part2,part3] = low_level_load(data);

                p1_data{idx_used_for_saving_data} = part1;
                p2_data{idx_used_for_saving_data} = part2;
                p3_data{idx_used_for_saving_data} = part3;

            else
                if isfile(filename) && isfile(filename2) && isfile(filename3)
                    load(filename);
                    order(end + 1) = index;
                else
                    continue;
                end

                part1.label = data.label;
                part1.time = data.time{1};
                part1.trialinfo = [1];
                part1.elec = data.elec;
                part1.dimord = 'chan_time';
                part1.thin = data.thin;
                part1.med = data.med;
                part1.thick = data.thick;

                if ~iscell(data.med)
                    part1.avg = data.med - (data.thin + data.thick) / 2;
                else
                    data.med = data.med(2:end);
                    data.thin = data.thin(2:end);
                    data.thick = data.thick(2:end);
                    pgi = {};
                    mindat = min([length(data.med), length(data.thin), length(data.thick)]);

                    for i = 1:mindat
                        pgi{i} = data.med{i} - (data.thin{i} + data.thick{i}) / 2;
                    end

                    part1.avg = pgi;
                end

                data2 = load(filename2).data;

                part2.label = data2.label;
                part2.time = data2.time{1};
                part2.trialinfo = [1];
                part2.elec = data2.elec;
                part2.dimord = 'chan_time';
                part2.thin = data2.thin;
                part2.med = data2.med;
                part2.thick = data2.thick;

                if ~iscell(data2.med)
                    part2.avg = data2.med - (data2.thin + data2.thick) / 2;
                else
                    data2.med = data2.med(2:end);
                    data2.thin = data2.thin(2:end);
                    data2.thick = data2.thick(2:end);
                    pgi = {};
                    mindat = min([length(data2.med), length(data2.thin), length(data2.thick)]);

                    for i = 1:mindat
                        pgi{i} = data2.med{i} - (data2.thin{i} + data2.thick{i}) / 2;
                    end

                    part2.avg = pgi;
                end

                data3 = load(filename3).data;

                part3.label = data3.label;
                part3.time = data3.time{1};
                part3.trialinfo = [1];
                part3.elec = data3.elec;
                part3.dimord = 'chan_time';
                part3.thin = data3.thin;
                part3.med = data3.med;
                part3.thick = data3.thick;

                if ~iscell(data3.med)
                    part3.avg = data3.med - (data3.thin + data3.thick) / 2;
                else
                    data3.med = data3.med(2:end);
                    data3.thin = data3.thin(2:end);
                    data3.thick = data3.thick(2:end);
                    pgi = {};
                    mindat = min([length(data3.med), length(data3.thin), length(data3.thick)]);

                    for i = 1:mindat
                        pgi{i} = data3.med{i} - (data3.thin{i} + data3.thick{i}) / 2;
                    end

                    part3.avg = pgi;
                end

                p1_data{idx_used_for_saving_data} = part1;
                p2_data{idx_used_for_saving_data} = part2;
                p3_data{idx_used_for_saving_data} = part3;
            end

            idx_used_for_saving_data = idx_used_for_saving_data + 1;
        end

    end

    if ~strcmp(onsets_part, 'onsets') && ~strcmp(onsets_part, 'eyes') && ~strcmp(onsets_part, 'partition1') && ~strcmp(onsets_part, 'partitions-vs-onsets')
        ft_data.part1 = p1_data;
        ft_data.part2 = p2_data;
        ft_data.part3 = p3_data;
    elseif strcmp(onsets_part, 'partitions-vs-onsets')

        p1.part1 = on_23_p1;
        p1.part2 = on_45_p1;
        p1.part3 = on_67_p1;

        p2.part1 = on_23_p2;
        p2.part2 = on_45_p2;
        p2.part3 = on_67_p2;

        p3.part1 = on_23_p3;
        p3.part2 = on_45_p3;
        p3.part3 = on_67_p3;

        ft_data.part1 = p1;
        ft_data.part2 = p2;
        ft_data.part3 = p3;
    end

end
