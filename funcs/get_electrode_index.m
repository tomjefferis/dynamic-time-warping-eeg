function [elec_index] = get_electrode_index(data, electrode)

% gets electrode index for given electrode
% Use as:
%       get_electrode_index(data, electrode)
%   Where data is a FT data object returned from FT_TIMELOCKANALYSIS
%   and electrode is a string of the desired electrode




    if iscell(data)
        data_point = data{1, 1}.elec.label;
    else
        data_point = data.label;
    end

    for index = 1:numel(data_point)

        if strcmp(data_point(index), electrode.electrode)
            elec_index = index;
            return;
        end

    end

    elec_index = 24;
    return;

end