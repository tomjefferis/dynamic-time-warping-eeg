function [mean_val, corrected_std, t_value, p_value] = compute_jackknife_statistics(jackknife_values, n_subjects, test_value, alpha)
% COMPUTE_JACKKNIFE_STATISTICS Computes corrected statistics for jackknife values
%
% Inputs:
%   jackknife_values - Vector of jackknife values
%   n_subjects - Total number of subjects
%   test_value - Optional value to test against (default = 0)
%   alpha - Significance level (default = 0.05)
%
% Outputs:
%   mean_val - Mean of jackknife values
%   corrected_std - Corrected standard deviation (Miller et al., 1998)
%   t_value - t-statistic for one-sample t-test
%   p_value - p-value for t-test

if nargin < 3 || isempty(test_value)
    test_value = 0;
end

if nargin < 4 || isempty(alpha)
    alpha = 0.05;
end

% Calculate mean
mean_val = mean(jackknife_values);

% Calculate corrected standard deviation
% Based on Miller et al. (1998): SD_corrected = sqrt(n-1) * SD
corrected_std = sqrt(n_subjects-1) * std(jackknife_values);

% Calculate corrected standard error
corrected_se = corrected_std / sqrt(n_subjects);

% Calculate t-value 
t_value = (mean_val - test_value) / corrected_se;

% Calculate p-value (two-sided)
p_value = 2 * (1 - tcdf(abs(t_value), n_subjects-1));

end
