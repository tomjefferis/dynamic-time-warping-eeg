addpath funcs\;
addpath 'Legacy Code'\generate_signals\;
addpath 'Legacy Code'
addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
if ~contains(path,'W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906\preproc')
    addpath('W:\PhD\MatlabPlugins\fieldtrip-20210906'); % path to fieldtrip
end

sig2s = sig1s/2;

subplot(2,1,1)
plot(x, sig1s)
plot(x,sig1s, 'LineWidth',2)
hold on
yline(0)
area(x(332:end), sig1s(332:end))

sig1area = trapz(x(332:end), sig1s(332:end));
% x line at the point 50% of the area is reached using cumtrapz
xline(x(find(cumtrapz(x(332:end), sig1s(332:end))>sig1area/2,1)+331), "LineWidth", 2)



subplot(2,1,2)
plot(x, sig2s)
plot(x,sig2s, 'LineWidth',2)
hold on
yline(0)
area(x(332:end), sig2s(332:end))

xline(x(find(cumtrapz(x(332:end), sig2s(332:end))>sig1area/2,1)+331), "LineWidth", 2)


