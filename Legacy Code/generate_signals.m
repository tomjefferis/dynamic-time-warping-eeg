function S  = generate_signals(s, num_samples, n_trials, width_lag)

    sig1=0;
    sig2=0.1;
    S=zeros(num_samples, n_trials); % matrix containing all data

    TAU=round((rand(1,n_trials)-0.5)*width_lag);

    for i=1:n_trials
        tau=TAU(i);

        if(tau<0)
            S(:,i)=[s(-1*tau:end)'; zeros(-1*(tau+1),1)];
        else
            S(:,i)=[zeros(tau,1);s(1:num_samples-tau)'; ];
        end
        
        if(i<50)
           S(:,i)=S(:,i) + randn(num_samples,1).*sig1;
        else
            S(:,i)=S(:,i) + randn(num_samples,1).*sig2;
        end
    end
end