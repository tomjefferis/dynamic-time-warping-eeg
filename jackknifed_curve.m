% generate gaussian curve funtcton, with setting for amplitude, latency, and width
function [curve] = gen_curves(timeRange, amplitude, latency, width)
    % JACKKNIFED_CURVE Generate a Gaussian curve with specified parameters
    %
    % Inputs:
    %   timeRange - Vector of time points (in ms) to generate the curve
    %   amplitude - Peak amplitude of the Gaussian curve (in v)
    %   latency   - Center of the Gaussian curve (in ms)
    %   width     - Width of the Gaussian curve (in ms), corresponds to standard deviation
    %
    % Outputs:
    %   time      - Same as timeRange input
    %   curve     - Generated Gaussian curve values
    %
    % Example:
    %   [t, c] = jackknifed_curve(-200:800, 5, 300, 50);
    %   plot(t, c);
    
    % Make sure timeRange is a row vector
    timeRange = reshape(timeRange, 1, []);
    
    % Calculate the Gaussian curve
    % The formula is: amplitude * exp(-((t - latency)^2) / (2 * width^2))
    curve = amplitude * exp(-((timeRange - latency).^2) ./ (2 * width^2));
    

    end



% generate gaussian curve and pl;ot it
timeRange = -200:800;
amplitude = 5;
latency = 300;
width = 50;

% params for latency analysis
n_sigs = 5;
jitter = [-30, 30];
amp_deviation = [-2, 2];
outlier_amp = 20;
n_outliers = 1;


n_outliers = 1:n_outliers;

curves = [];

figure;
for i = 1:n_sigs
   
    % Add some random jitter to the latency
    lat = latency + randi(jitter);
    
    % Add some random deviation to the amplitude
    amp = amplitude + randi(amp_deviation);
    
    % Add some outliers to the amplitude
    if ismember(i, n_outliers)
        amp = amplitude + outlier_amp;
        lat = lat + 70;
    end
    
    % Generate the Gaussian curve
    [curve] = gen_curves(timeRange, amp, lat, width);

    % Store the curve for later use
    curves = [curves; curve];
    
    % Plot the Gaussian curve, line width 2
    plot(timeRange, curve, 'LineWidth', 2);
    hold on;
end

% Calculate the peak time for each curve
peak_times = zeros(n_sigs, 1);
for i = 1:n_sigs
    [~, peak_idx] = max(curves(i, :));
    peak_times(i) = timeRange(peak_idx);
end
mean_peak_time = mean(peak_times);
std_peak_time = std(peak_times);
min_peak_time = min(peak_times);
max_peak_time = max(peak_times);

% Add vertical line at the mean peak time
xline(mean_peak_time, '--r', ['Mean peak time: ' num2str(mean_peak_time) ' ms'], 'LineWidth', 1.5, 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'left');

title('Gaussian Curves');

% Add inset with statistics
inset_ax = axes('Position', [0.15, 0.60, 0.25, 0.25]);
axis off;
box on;
range_value = max_peak_time - min_peak_time;
stats_text = {
    ['Mean: ' num2str(mean_peak_time, '%.1f') ' ms'],
    ['SD: ' num2str(std_peak_time, '%.1f') ' ms'],
    ['Range: ' num2str(range_value, '%.1f') ' ms (' num2str(min_peak_time, '%.1f') ' - ' num2str(max_peak_time, '%.1f') ')'],
    ['N: ' num2str(n_sigs)]
};
text(0.05, 0.9, 'Peak Statistics:', 'FontWeight', 'bold');
for i = 1:length(stats_text)
    text(0.05, 0.9 - i*0.2, stats_text{i});
end

% jackknifed curve
jackknifed_curves = [];

figure;
for i = 1:size(curves,1)
    % Remove the current curve from the list
    curves_temp = curves;
    curves_temp(i, :) = [];
    
    % Calculate the mean of the remaining curves
    jackknife_curve = mean(curves_temp, 1);
    
    % Store the jackknifed curve
    jackknifed_curves = [jackknifed_curves; jackknife_curve];
    
    % Plot the jackknifed curve, line width 2
    plot(timeRange, jackknife_curve, 'LineWidth', 2);
    hold on;
end

% Calculate the peak time for each jackknifed curve
jackknife_peak_times = zeros(size(jackknifed_curves, 1), 1);
for i = 1:size(jackknifed_curves, 1)
    [~, peak_idx] = max(jackknifed_curves(i, :));
    jackknife_peak_times(i) = timeRange(peak_idx);
end
mean_jackknife_peak_time = mean(jackknife_peak_times);
std_jackknife_peak_time = std(jackknife_peak_times);
min_jackknife_peak_time = min(jackknife_peak_times);
max_jackknife_peak_time = max(jackknife_peak_times);

% Add vertical line at the mean peak time
xline(mean_jackknife_peak_time, '--r', ['Mean peak time: ' num2str(mean_jackknife_peak_time) ' ms'], 'LineWidth', 1.5, 'LabelOrientation', 'horizontal');

title('Jackknifed Curves');

% Add inset with jackknife statistics
inset_ax = axes('Position', [0.15, 0.60, 0.25, 0.25]);
axis off;
box on;
jackknife_range_value = max_jackknife_peak_time - min_jackknife_peak_time;
jackknife_stats_text = {
    ['Mean: ' num2str(mean_jackknife_peak_time, '%.1f') ' ms'],
    ['SD: ' num2str(std_jackknife_peak_time, '%.1f') ' ms'],
    ['Range: ' num2str(jackknife_range_value, '%.1f') ' ms (' num2str(min_jackknife_peak_time, '%.1f') ' - ' num2str(max_jackknife_peak_time, '%.1f') ')'],
    ['N: ' num2str(size(jackknifed_curves, 1))]
};
text(0.05, 0.9, 'Jackknife Peak Statistics:', 'FontWeight', 'bold');
for i = 1:length(jackknife_stats_text)
    text(0.05, 0.9 - i*0.2, jackknife_stats_text{i});
end

