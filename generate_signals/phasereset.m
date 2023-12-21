function signal = phasereset (frames, epochs, srate, minfr, maxfr, position, tjitter)

% function signal = phasereset (frames, epochs, srate, minfr, maxfr {, position, tjitter)
%
% Function generates signal composed of a single sinusoid whose phase is
% being reset. The frequency of the sinusoid is chosen randomly from a
% specified range [minfr, maxfr]. The initial phase of the sinusoid is chosen randomly.
% Required inputs:
%  frames - number of signal frames per each trial
%  epochs - number of simulated trials
%  srate - sampling rate of simulated signal
%  minfr - minimum frequency of the sinusoid which is being reset
%  maxfr - maximum frequency of the sinusoid which is being reset
% Optional inputs:
%  position - position of the reset [in frames]; default: frames/2 => in the middle
%  tjitter - stdev of time jitter of the reset [in frames]; default: 0 => no jitter
% Output:
%  signal - simulated EEG signal; vector: 1 by frames*epochs containing concatenated trials
% Implemented by: Rafal Bogacz and Nick Yeung, September 2006

if nargin < 6
   position = frames / 2;
end
if nargin < 7
   tjitter = 0;
end

%generating the wave
signal = zeros (1, epochs * frames);
for trial = 1:epochs
    wavefr = rand(1) * (maxfr-minfr) + minfr;   
    initphase = rand(1) * 2 * pi;
    pos = position + round(randn(1)*tjitter);
    for i=1:frames
        if i < pos
            phase = i/srate*2*pi*wavefr + initphase;
        else
            phase = (i-pos)/srate*2*pi*wavefr;
        end
        signal((trial-1)*frames+i) = sin(phase);
    end
end
