function [sig1, sig2] = ERPGenerate(sigLen, fs, variance, SNR, baseline,latencyDiff)

    addpath generate_signals/


    % Generate ERP signal
    sig1 = genericERP(fs, sigLen, baseline, variance, SNR);
    sig2 = genericERP(fs, sigLen, baseline, variance, SNR);

    % Add latency difference
    % append x amout of samples from the beginning of sig1 or sig2 depending on latencyDiff being positive or negative

    if latencyDiff > 0
        sig1_ext = fliplr(sig1(1:latencyDiff));
        sig1 = [sig1_ext, sig1(1:end-latencyDiff)];
    elseif latencyDiff < 0
        sig2_ext = fliplr(sig2(1:abs(fs*latencyDiff)));
        sig2 = [sig2_ext, sig2(1:end-abs(fs*latencyDiff))];
    end



end