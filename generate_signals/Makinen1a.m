function Makinen1a

% function Makinen1a
%
% function plots the Figure 1a from the Makinen et al. (2005)

trials = 30;

mysig = Makinen (400, trials, 1000, 175);
mysig = reshape (mysig, 400, trials);

subplot (3,1,1);
plot (mysig);
ylabel ('EEG');
subplot (3,1,2);
plot (mean(mysig'));
ylabel ('ERP');
subplot (3,1,3);
plot (var(mysig'));
ylabel ('Variance');