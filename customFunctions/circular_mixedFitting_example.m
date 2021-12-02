clear all; close all; clc; %#ok

%% Boilerplate
xarr = -179:1:180;
unif = repmat(1/length(xarr),1,length(xarr));

%% Custom function
MixPDF = @(x,m,sd,weight) (weight*normpdf(x,m,sd) + (1-weight) * 1/length(xarr)); % mix of Gaussian and uniform

% Main
data = randsample(xarr,100000,true,MixPDF(xarr,0,20,0.88));
p = mle(data, 'pdf', MixPDF, 'start', [0 10 0.5], 'lowerbound', [-179 0.1 0], 'upperbound', [180 66 1]);

%% Log likelihood
ll = sum(log(MixPDF(data,p(1),p(2),p(3))));
AIC = -2*ll + 2*length(p);

%ll_bad = sum(log(MixPDF(data,10,30,0.5))); % for comparison, bigger(less negative) is better
%AIC_bad = -2*ll_bad + 2*length(p); % Smaller is better (-2 is a standard cutoff)

%% Plot
figure(); hold on;
histogram(data,'Normalization','pdf')
plot(xarr,MixPDF(xarr,p(1),p(2),p(3)),'-r');
xlim([xarr(1) xarr(length(xarr))]);
legend('Observed Samples','Fitted Distribution');

%% End
disp('Done!');