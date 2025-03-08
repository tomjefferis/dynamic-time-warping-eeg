% Computes the electrode with the largest or smallest t-value for a given
% cluster of a statistical analysis. The function takes in a `stat` struct
% containing the statistical analysis results, a `type` string indicating
% whether to look for positive or negative clusters, and an optional `cluster`
% integer indicating which cluster to look for (default is 1). The function
% returns a struct `significant_electrode` containing the name of the
% significant electrode, the time point of the peak t-value, the peak t-value,
% and the start and end time points of the significant cluster.
%
% Usage: [significant_electrode] = compute_best_electrode(stat, type, cluster)
%
% Inputs:
%   - stat: a struct containing the statistical analysis results, with fields:
%       - stat: a matrix of t-values for each electrode and time point
%       - time: a vector of time points
%       - label: a cell array of electrode names
%       - posclusterslabelmat: a matrix indicating which positive clusters each
%         electrode and time point belongs to
%       - negclusterslabelmat: a matrix indicating which negative clusters each
%         electrode and time point belongs to
%   - type: a string indicating whether to look for positive or negative clusters
%   - cluster: an optional integer indicating which cluster to look for (default is 1)
%
% Outputs:
%   - significant_electrode: a struct containing the following fields:
%       - electrode: the name of the significant electrode
%       - time: the time point of the peak t-value
%       - t_value: the peak t-value
%       - sig_start: the start time point of the significant cluster
%       - sig_end: the end time point of the significant cluster
function [significant_electrode] = compute_best_electrode(stat, type, cluster)

    % Set default value for cluster if not provided
    if ~exist('cluster','var')
        cluster = 1;
    end

    % Extract relevant fields from stat argument
    t_values = stat.stat;
    time = stat.time;
    electrodes = stat.label;

    % Determine which clusters to look for based on type argument
    if contains(type, 'positive')
        cluster_matrix_locations = stat.posclusterslabelmat;
    elseif contains(type, 'negative')
        cluster_matrix_locations = stat.negclusterslabelmat;
    end

    % Iterate over each electrode and time point
    peak_level_stats = containers.Map;
    [rows, columns] = size(cluster_matrix_locations);
    for col = 1:columns
        for row = 1:rows
            t_value = t_values(row, col);
            t = time(col);
            electrode = electrodes{row};
            which_cluster = cluster_matrix_locations(row, col);
            if which_cluster == cluster
                keys = peak_level_stats.keys;
                if any(strcmp(keys, electrode))
                    previous_values = peak_level_stats(electrode);
                    previous_t = previous_values{2};
                    if t_value > previous_t && contains(type, 'positive')
                        peak_level_stats(electrode) = {t, t_value, col};
                    elseif t_value < previous_t && contains(type, 'negative')
                        peak_level_stats(electrode) = {t, t_value, col};
                    end
                else
                    peak_level_stats(electrode) = {0, 0, 0};
                end
            end
        end
    end

    % Find electrode with largest/smallest t-value
    keys = peak_level_stats.keys;
    significant_electrode.electrode = '';
    significant_electrode.time = 0;
    significant_electrode.t_value = 0;
    for i = 1:numel(keys)
        electrode = keys{i};
        stats = peak_level_stats(electrode);
        t_value = stats{2};
        time = stats{1};
        significant_electrode.max_indx = stats{3};
        if t_value > significant_electrode.t_value && contains(type, 'positive')
            significant_electrode.electrode = electrode;
            significant_electrode.time = time;
            significant_electrode.t_value = t_value;
        elseif t_value < significant_electrode.t_value && contains(type, 'negative')
            significant_electrode.electrode = electrode;
            significant_electrode.time = time;
            significant_electrode.t_value = t_value;
        end
    end

    % Determine start and end time points of significant cluster
    start_clus= -1;
    end_clus = -1;
    for col = 1:columns
        if any(cluster_matrix_locations(:,col) == 1)
            if start_clus == -1
                start_clus = col;
            else
                end_clus = col;
            end
        end
    end
    significant_electrode.sig_start = stat.time(start_clus);
    significant_electrode.sig_start_index = start_clus;
    try
        significant_electrode.sig_end =  stat.time(end_clus);
        significant_electrode.sig_end_index = end_clus;
    catch
        significant_electrode.sig_end =  stat.time(end);
        significant_electrode.sig_endt_index = length(stat.time);
    end

end