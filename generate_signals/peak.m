function signal = peak (frames, epochs, srate, peakfr, position, tjitter, wave)

% function signal = peak (frames, epochs, srate, peakfr {, position, tjitter, wave})
%
% Function generates signal composed of a single peak in each epoch
% Required inputs:
%  frames - number of signal frames per each trial
%  epochs - number of simulated trials
%  srate - sampling rate of simulated signal
%  peakfr - frequency of sinusoid whos half of the cycle is taken to form the peak
% Optional inputs:
%  position - position of the peak [in frames]; default: frames/2 => in the middle
%  tjitter - stdev of time jitter of the peak; default: 0 => no jitter
%  wave - if defined the signal is composed not from a peak, but complete sinusoid. 
% Output:
%  signal - simulated EEG signal; vector: 1 by frames*epochs containing concatenated trials
% Implemnted by: Rafal Bogacz and Nick Yeung, Princeton Univesity, December 2002

if nargin < 5
   position = frames / 2;
end
if nargin < 6
   tjitter = 0;
end
if nargin < 7
   wave = 0;
end

%generating peak
signal = zeros (1, epochs * frames);
for trial = 1:epochs
 pos = position + round(randn(1)*tjitter);
 for i=1:frames
   phase = (i-pos)/srate*2*pi*peakfr;
   if wave | (phase < pi/2 & phase > -pi/2)
      signal((trial-1)*frames+i) = cos(phase);
   end
 end
end
