function signal = Makinen (frames, epochs, srate, position)

% function signal = Makinen (frames, epochs, srate {, position)
%
% Function generates signal as described in the paper of Makinen et al.
% (2005). Namely, it is a sum 4 sinusoids with frequencies chosen randomly
% from range 4-16Hz, with random initial phase. The phase of these
% oscillations is being reset at a specified position.
% Required inputs:
%  frames - number of signal frames per each trial
%  epochs - number of simulated trials
%  srate - sampling rate of simulated signal
% Optional input:
%  position - position of the reset [in frames]; default: frames/2 => in the middle
% Output:
%  signal - simulated EEG signal; vector: 1 by frames*epochs containing concatenated trials
% Implemented by: Rafal Bogacz and Nick Yeung, September 2006

if nargin < 4
   position = frames / 2;
end

%generating the wave
signal = zeros (1, epochs * frames);
for i = 1:4
    signal = signal + phasereset (frames, epochs, srate, 4, 16, position);
end
