function outdata = calc_boot(resp,design,doplot)

if isempty(doplot)
    doplot = 0;
end

acc = mean(resp==design);
% calc bootstrap sig
nits = 1000;
bacc = zeros(1,nits);
for i = 1:nits
    bacc(i) = mean(design(randperm(length(design))) == resp);
end
[f,x] = ecdf(bacc);
p = 1-f(findnearest(acc,x));
if length(p)>1
    p=p(end);
end
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

outdata.probs = probs;
outdata.diffx = diffx;
outdata.p = p;
outdata.x = x;
outdata.f = f;
outdata.acc = acc;

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

end