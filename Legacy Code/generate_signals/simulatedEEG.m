function data = simulatedEEG

% function data = simulatedEEG
%
% Fuction generages the signal used in the simulations
% The signal is in a matrix in a format of the Matlab EEG toolbox

%general parameters of the signal
FRAMES = 200;
TRIALS = 973;
SRATE = 250;
%parameters of NE
NEAMP = -24;
NEFREQ = 5;
NEPOS = 115;
%parameters of PE
PEAMP = 11;
PEFREQ = 1;
PEPOS = 150;
%temporal jitter of peaks and amplitude of noise
TJITTER = 8;
NOISEAMP = 10;

disp ('Please wait while generating the data');

ne = NEAMP * peak (FRAMES, TRIALS, SRATE, NEFREQ, NEPOS, TJITTER);
pe = PEAMP * peak (FRAMES, TRIALS, SRATE, PEFREQ, PEPOS, TJITTER, 1);

load dipole

data = dipole (:, 1) * ne + dipole (:, 4) * pe;
for ch = 1:size(data,1)
 disp(sprintf('Generating noise for channel %d', ch));
 data(ch,:) = data(ch,:) + NOISEAMP * noise (FRAMES, TRIALS, SRATE);
end