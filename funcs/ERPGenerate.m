function [sig1, sig2] = ERPGenerate(sigLen, fs, variance, SNR, baseline,latencyDiff)



    % Generate ERP signal
    sig1s = genericERP(fs, sigLen, baseline, variance, SNR);
    sig2s = genericERP(fs, sigLen, baseline, variance, SNR);

    % Add latency difference
    % append x amout of samples from the beginning of sig1 or sig2 depending on latencyDiff being positive or negative

    if latencyDiff > 0
        num = round(abs(fs*latencyDiff));
        sig1_ext = fliplr(sig1s(1:num));
        sig1s = [sig1_ext, sig1s(1:end-num)];
    elseif latencyDiff < 0
        num = round(abs(fs*latencyDiff));
        sig2_ext = fliplr(sig2s(1:num));
        sig2s = [sig2_ext, sig2s(1:end-num)];
    end

    sig1{1}.erp = sig1s';
    sig2{1}.erp = sig2s';


end