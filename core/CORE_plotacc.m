function [] = CORE_plotacc(acc,badsub)



% plot acc values for various conditions
condcolor = {'g','b','r','k'};
condmarker = {'^-','s--','o-.'};
levels = {'all','faces','scenes'};
%levels = {'all'};
figure('color','white');

if exist('badsub','var')
    for ilevel = 1:length(levels)
        acc.(levels{ilevel}) = acc.(levels{ilevel})(~badsub,:);
    end
end
minacc =1;
for i = 1:length(levels)
    if size(acc.(levels{1}))>1
        accmean = mean(acc.(levels{i}));
        accsem = ste(acc.(levels{i}));
    else
        accmean = acc.(levels{i});
        accsem = zeros(1,length(accmean));
    end
    minacc = min([min(accmean) minacc]);
    h(i)=errorbar(accmean,accsem,[condmarker{i}],'Color',[.4 .4 .4],'markersize',10,'linewidth',3);
    hold on
    for j = 1:length(accmean)         
        plot(j,accmean(j),[condcolor{j} condmarker{i}],'markersize',10,'linewidth',5);
    end
end
box off;
xlim([.5,4.5]);
ylim([minacc-.05, 1.001]);
legend(h,levels,'location','Best');
legend boxoff
set(gca,'xtick',[]);
ylabel('Percent Correct','fontsize',20)
set(gca,'fontsize',20)
title(['N = ' num2str(size(acc.all,1))]);
    