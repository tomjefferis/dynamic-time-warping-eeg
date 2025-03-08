function [data] = low_level_split (data, label, freq)
% moves desired field to avg field and removes the rest
% see split_data function for description
    for idx = 1:numel(data)
        participant_data = data{idx};

        if ~isfield(participant_data, "med_powspctrm")
            if strcmp(label, "med")
                participant_data.avg = participant_data.med;
                participant_data = rmfield(participant_data, "med");
                participant_data = rmfield(participant_data, "thin");
                participant_data = rmfield(participant_data, "thick");
            elseif strcmp(label, "thin")
                participant_data.avg = participant_data.thin;
                participant_data = rmfield(participant_data, "med");
                participant_data = rmfield(participant_data, "thin");
                participant_data = rmfield(participant_data, "thick");
            elseif strcmp(label, "thick")
                participant_data.avg = participant_data.thick;
                participant_data = rmfield(participant_data, "med");
                participant_data = rmfield(participant_data, "thin");
                participant_data = rmfield(participant_data, "thick");
            end
        elseif freq && isfield(participant_data, "med_powspctrm")
            if strcmp(label, "med")
                participant_data.powspctrm = participant_data.med_powspctrm;
                participant_data = rmfield(participant_data, "med_powspctrm");
                participant_data = rmfield(participant_data, "thin_powspctrm");
                participant_data = rmfield(participant_data, "thick_powspctrm");
            elseif strcmp(label, "thin")
                participant_data.powspctrm = participant_data.thin_powspctrm;
                participant_data = rmfield(participant_data, "med_powspctrm");
                participant_data = rmfield(participant_data, "thin_powspctrm");
                participant_data = rmfield(participant_data, "thick_powspctrm");
            elseif strcmp(label, "thick")
                participant_data.powspctrm = participant_data.thick_powspctrm;
                participant_data = rmfield(participant_data, "med_powspctrm");
                participant_data = rmfield(participant_data, "thin_powspctrm");
                participant_data = rmfield(participant_data, "thick_powspctrm");
            end
        end

        %if freq
       %     participant_data.trial = participant_data.avg;
       %     participant_data = rmfield(participant_data, "avg");
        %end

        data{idx} = participant_data;
    end

end