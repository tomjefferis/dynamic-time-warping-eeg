% Parameters
x = linspace(-15, 15, 1000); % X-axis for the Gaussian curves

% First Gaussian curve
mu1 = -3;      % Mean of the first Gaussian
sigma1 = 3;    % Standard deviation of the first Gaussian
gaussian1 = exp(-(x - mu1).^2 / (2 * sigma1^2));

% Second Gaussian curve
mu2 = 4;       % Mean of the second Gaussian
sigma2 = 3.5;  % Standard deviation of the second Gaussian
gaussian2 = exp(-(x - mu2).^2 / (2 * sigma2^2));

% Find the peaks
[peak1, idx1] = max(gaussian1);
[peak2, idx2] = max(gaussian2);

% Calculate half-max values
halfMax1 = peak1 / 2;
halfMax2 = peak2 / 2;

% Find indices of points closest to half-max
[~, idxHalfMax1] = min(abs(gaussian1 - halfMax1));
[~, idxHalfMax2] = min(abs(gaussian2 - halfMax2));

% Plot the curves
figure;
plot(x, gaussian1, 'b', 'LineWidth', 2); hold on;
plot(x, gaussian2, 'r', 'LineWidth', 2);

% Highlight peaks with markers
scatter(x(idx1), peak1, 80, 'b', 'filled', 'MarkerEdgeColor', 'k'); % Peak for Gaussian 1
scatter(x(idx2), peak2, 80, 'r', 'filled', 'MarkerEdgeColor', 'k'); % Peak for Gaussian 2

% Highlight half-maximum points with markers
scatter(x(idxHalfMax1), gaussian1(idxHalfMax1), 80, 'b', 'd', 'filled', 'MarkerEdgeColor', 'k'); % Half-max for Gaussian 1
scatter(x(idxHalfMax2), gaussian2(idxHalfMax2), 80, 'r', 'd', 'filled', 'MarkerEdgeColor', 'k'); % Half-max for Gaussian 2

% Customize the plot
title('Two Offset Signals');
xlabel('X');
ylabel('Amplitude');
legend('Signal 1', 'Signal 2', 'Location', 'best');
grid on;
ylim([0 1.1])