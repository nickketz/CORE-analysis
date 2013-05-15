function outdata = core_acceval_persub(cfg,exper)

cfg.congcrit = .5;
[jnk, substruct] = core_getbehavmeas(exper,cfg);
conds = {'Green','Blue','Red','k'};
h1 = figure('color','white');
hold on

condvec = {};
condacc = {};
mycolors = jet(length(substruct));

for icond = 0:3
    mymax = nan(1,1);
    mymin = nan(1,1);
    subb = nan(length(substruct),2);
    
    fullvec = [];
    fullacc = [];
    if cfg.dosubplots==1
        h2=figure('color','white');
        hold on
    end
    for isub = 1:length(substruct)
        accvec = [];
        myvec = [];
        if exper.maxperf(isub).p < .1 || cfg.dofilt == 0
            if icond == 3
                ind = ismember(substruct(isub).cond,cfg.kconds);
            else
                ind = substruct(isub).cond==icond;
            end
            
            accvec = [accvec substruct(isub).acc(ind)];
            
            switch cfg.vectype
                case 'congdiff'
                    myvec = [myvec [substruct(isub).cong(ind) - substruct(isub).incong(ind)]];
                case 'pctcong'
                    myvec = [myvec substruct(isub).pctcong(ind)];
                case 'pctincong'
                    myvec = [myvec (1-substruct(isub).pctcong(ind))];
                case 'cong'
                    myvec = [myvec substruct(isub).cong(ind)];
                case 'incong'
                    myvec = [myvec substruct(isub).incong(ind)];
                case 'memact'
                    myvec = [myvec substruct(isub).memact(ind)];
                otherwise
                    error('unrecognized vector type');
            end            
            
            fullvec = [fullvec myvec];
            fullacc = [fullacc accvec];
            subvec{isub} = myvec;
            subacc{isub} = accvec;
            mymax = max([myvec mymax]);
            mymin = min([myvec mymin]);            
            
            [b,dev,stats] = glmfit(myvec,accvec','binomial','link','logit');
            subb(isub,:) = b;
            
            if cfg.dosubplots ==1
                mybins = linspace(min(myvec),max(myvec),cfg.nbins+1);
                interval = diff(mybins)./2;
                mybins = mybins(1:end-1)+interval;
                [temp,whichbin] = histc(myvec,mybins);
                for ibin = 1:cfg.nbins
                    myacc(ibin) = mean(accvec(whichbin==ibin));
                end
                xdata = linspace(min(myvec),max(myvec),100);
                yfit = glmval(subb(isub,:)',xdata,'logit');
                plot(xdata,yfit,'color',mycolors(isub,:));
                plot(mybins,myacc,'.','color',mycolors(isub,:),'markersize',10)
            end            
            
            if isub==1
                substats = stats;
            else
                substats(isub) = stats;
            end
            goodsubs(isub) = 1;
        else
            goodsubs(isub) = 0;
        end
        
    end
    if cfg.dosubplots == 1
        title(sprintf('Sub plots %s', conds{icond+1}));
    end
    
    goodsubs = logical(goodsubs);
    
    if cfg.normalize == 1
        stdmax = (3*std(fullvec))+mean(fullvec);
        stdmin = mean(fullvec)+(-3*std(fullvec));
        grpmean = mean(fullvec);
        outliers = fullvec>stdmax | fullvec<stdmin;
        fullvec(outliers) = [];
        fullacc(outliers) = [];
        fullvec = normalize(fullvec);
        mymin = 0;
        mymax = 1;
    end        
    
    condvec{icond+1} = fullvec;
    condacc{icond+1} = fullacc;
    
    if cfg.persub == 1
        n = nan(length(subvec),cfg.nbins);
        for isub = 1:length(subvec)
            if goodsubs(isub)
                mybins = linspace(mymin,mymax,cfg.nbins+1);
                [temp,whichbin] = histc(subvec{isub},mybins);
                n(isub,:) = temp(1:end-1);
                n(isub,end) = temp(end)+n(isub,end);
                for ibin = 1:cfg.nbins
                    myacc(ibin) = mean(subacc{isub}(whichbin==ibin));
                end
                subbinacc{isub} = myacc;
            end
        end
        myste = [];
        myacc = [];
        for ibin = 1:cfg.nbins
            myacc(ibin) = nanmean(cellfun(@(x)(x(ibin)),subbinacc(goodsubs)));
            myste(ibin) = nanste(cellfun(@(x)(x(ibin)),subbinacc(goodsubs))');
        end
    else %megaparticipant
        n = nan(1,cfg.nbins);
        mybins = linspace(0,1,cfg.nbins+1);
        [temp,whichbin] = histc(fullvec,mybins);
        n = temp(1:end-1);
        n(end) = temp(end)+n(end);
        myacc = [];
        myste = [];
        for ibin = 1:cfg.nbins
            myacc(ibin) = mean(fullacc(whichbin==ibin));
            myste(ibin) = ste(fullacc(whichbin==ibin));
        end
    end
       

    
    if cfg.plotconds(icond+1)==1
        set(0,'CurrentFigure',h1);
        interval = diff(mybins)./2;
        mybins = mybins(1:end-1)+interval;
        xdata = linspace(mymin,mymax,100);
        if cfg.persub ==1
            yfit = glmval(nanmean(subb)',xdata,'logit');
        else
            [b,dev,stats] = glmfit(fullvec,fullacc','binomial','link','logit');
            yfit = glmval(b,xdata,'logit');
        end
        plot(xdata,yfit,['-' lower(conds{icond+1}(1))]);
        errorbar(mybins,myacc,myste,['s' lower(conds{icond+1}(1))],'linewidth',2,'markersize',10,'markerfacecolor',lower(conds{icond+1}(1)));
        xlabel(cfg.vectype,'fontsize',20);
        ylabel('Accuracy','fontsize',20);
        box off
        set(gca,'fontsize',20);
        %ylim([0 1]);
    end
    
    outdata.(conds{icond+1}).bins = mybins;
    outdata.(conds{icond+1}).acc = myacc;
    outdata.(conds{icond+1}).n = n;
    outdata.(conds{icond+1}).b = subb;
    outdata.(conds{icond+1}).bfull = b;
    outdata.(conds{icond+1}).substats = substats;
    outdata.(conds{icond+1}).fullstats = stats;
    
    [h,p,ci,stats] = ttest(subb);
    outdata.(conds{icond+1}).p = p;
    outdata.(conds{icond+1}).tstats = stats;

end
outdata.cfg = cfg;
%legend({'Green','Blue','Red','Blue and Red'},'Location','Best');

% figure('color','white')
% hold on
% for icond = 0:2
%     yfit = glmval(mean(outdata.(conds{icond+1}).b)',condvec{icond+1},'logit');
%     plot(condvec{icond+1},yfit,[ lower(conds{icond+1}(1)) '.' ],'markersize',10);
% end
% ylabel('Fit Accuracy');
% xlabel(cfg.vectype);
% set(gca,'fontsize',16);




