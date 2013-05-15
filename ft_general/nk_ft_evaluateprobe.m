function outdata = nk_ft_evaluateprobe(test_stat,design,doplot)
% evaluates test results from probed model
%
%   input:
%       test_stat = struc returned from nk_ft_probemodel, must contain
%       'result' field
%       design = design matrix with ground truth
%
%   output:
%       outdata = struc containing fields:
%           resp = response estimated from max difference between conds
%           accuracy = accuracy of resp against design
%           p = bootstrapped p value against from permutation test
%

if ~exist('doplot','var')
    doplot = 0;
end
    

mydif = zeros(size(test_stat(1).result,1),length(test_stat));
for i = 1:length(test_stat)
    mystat = test_stat(i).result;
    for j = 1:size(mystat,1)
        mydif(j,i) = mystat(j,1) - mystat(j,2);
    end
end

%% max difference    
[val, ival] = max(abs(mydif),[],2);
resp = zeros(1,length(ival));
maxdif = [];
for i = 1:length(ival)
    temp = test_stat(ival(i)).result(i,:);
    maxdif(i) = temp(1)-temp(2);
    if temp(1) > temp(2)
        resp(i) = 1;
    else
        resp(i) = 2;
    end
end
testind = design~=0;
designorig = design;
design = design(testind);
resporig = resp;
resp = resp(testind);
acc = mean(design == resp);

%% calc bootstrap sig

nits = 10000;
bacc = zeros(1,nits);
for i = 1:nits
    bacc(i) = mean(design(randperm(length(design))) == resp);
end
[f,x] = ecdf(bacc);
p = 1-f(findnearest(acc,x));
%calc probabilities
temp = diff(f);
probs = zeros(1,length(temp));
imean = findnearest(f,.5);
for i = 1:length(f)
    if i>=imean
        probs(i)=1-f(i);
    else
        probs(i)=f(i);
    end
end

diffx = x(1:end-1)+diff(x);
[diffx,ui] = unique(x);
probs= probs(ui);

outdata.resp = resporig;
outdata.acc = acc;
outdata.respind = ival;
outdata.p = probs(findnearest(acc,diffx));
outdata.design = design;

myind = sub2ind(size(mydif),1:size(mydif,1),ival');
outdata.maxdiff = mydif(myind);

% close all
% figure('color','white');
% plot(x,f,'linewidth',5);
% hold on
% plot(repmat(x(findnearest(acc,x)),1,2),ylim,'--r','linewidth',3);
% box off

if doplot ==1
    figure('color','white');
    bar(diffx,probs);
    hold on
    plot(repmat(diffx(findnearest(acc,diffx)),1,2),ylim,'--r','linewidth',3);
    box off
    xlabel('classifier accuracy','fontsize',22)
    ylabel('probability of observation','fontsize',22)
    set(gca,'fontsize',22);
    ylim([0 max(probs)]);
    xlim([min(x) max(x)]);
    title(['Subject ' num2str(test_stat(1).subNo)]);
    drawnow;
end




