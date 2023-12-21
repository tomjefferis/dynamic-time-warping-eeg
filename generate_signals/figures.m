function figures

% function figures
%
% Function generates sample Figures from the paper

FRAMES = 200;
SRATE = 250;
FCz = 11;

data = simulatedEEG;
xaxis = [-(FRAMES/2-1)/SRATE*1000 : 1/SRATE*1000 : FRAMES/2/SRATE*1000];

%Figure 2c - sample simulated trials
figure (1);
for i = 1:10;
 subplot(12, 1, i);
 plot (xaxis, matsel (data, FRAMES, 0, FCz, i));
 axis off
end
subplot (6, 1, 6);
plot (xaxis, blockave (data(FCz,:), FRAMES, [1:20]));

%Figure 3c - the averaged ERP
figure (2);
erp = blockave (data, FRAMES);
erp = rmbase (erp); 
timtopo (erp, 'nickloc31.locs', [-400 400 -12 12], [-348 -248 -148 -48 52 152 252 352], ...
	 'Figure 3ce - the averaged ERP', FCz);
