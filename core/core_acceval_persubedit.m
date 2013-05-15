function outdata = core_acceval_persubedit(cfg,exper,origacc)

cfg.congcrit = .5;
if ~isfield(cfg,'sthres')
    cfg.sthres = 5;
end
[jnk, substruct] = core_getbehavmeas(exper,cfg);
conds = {'Green','Blue','Red','k'};
h1 = figure('color','white');
hold on

condvec = {};
condacc = {};
mycolors = jet(length(substruct));

switch cfg.imgt
    case 0
        myacc = mean(origacc.scenes);
    case 1
        myacc = mean(origacc.faces);
    case 2
        myacc = mean(origacc.all);
end
myacc(end+1) = mean(myacc(cfg.kconds(1):cfg.kconds(2)));
origacc = myacc;
        

for icond = 0:3
    mymax = nan(1,1);
    mymin = nan(1,1);
    subb = nan(length(substruct),2);
    
    fullvec = [];
    fullacc = [];
    fullimgt = [];
    fullsub = [];
    fullcond = [];
    fullstim = [];
    if cfg.dosubplots==1
        h2=figure('color','white');
        hold on
    end
    for isub = 1:length(substruct)
        accvec = [];
        myvec = [];
        stimvec = [];
        imgtvec = [];
        ncondvec = [];
        %succvec = [];
        if isfield(exper,'maxperf')
            p = exper.maxperf(isub).p(1);
        else
            p = exper.trainresult(isub).p(1);
        end
        if p < .1 || cfg.dofilt == 0
            if icond == 3
                ind = ismember(substruct(isub).cond,cfg.kconds);
            else
                ind = substruct(isub).cond==icond;
            end
            
            if cfg.imgt ~= 2 % 2=> both faces and scenes allowed
                ind = intersect(find(ind),find(substruct(isub).imgt==cfg.imgt));
            end
            
            accvec = [accvec substruct(isub).acc(ind)];
            stimvec = [stimvec substruct(isub).stims(ind)];
            imgtvec = [imgtvec substruct(isub).imgt(ind)];
            ncondvec = [ncondvec substruct(isub).cond(ind)];
            %succvec = [succvec substrcut(isub).succ(ind)];
            
            switch cfg.vectype
                case 'congdiff'
                    myvec = substruct(isub).cong(ind) - substruct(isub).incong(ind);
                case 'pctcong'
                    myvec = substruct(isub).pctcong(ind);
                case 'pctincong'
                    myvec = (1-substruct(isub).pctcong(ind));
                case 'cong'
                    myvec = substruct(isub).cong(ind);
                case 'incong'
                    myvec = substruct(isub).incong(ind);
                case 'memact'
                    myvec = substruct(isub).memact(ind);
                case 'smemact'
                    myvec = substruct(isub).smemact(ind);
                case 'sumact'
                    myvec = substruct(isub).sumact(ind);
                case 'ssumact'
                    myvec = substruct(isub).ssumact(ind);
                otherwise
                    error('unrecognized vector type');
            end            
            
            fullvec = [fullvec myvec];
            fullacc = [fullacc accvec];
            fullimgt = [fullimgt imgtvec];
            fullsub = [fullsub repmat(isub,1,length(myvec))];
            fullcond = [fullcond ncondvec];
            fullstim = [fullstim stimvec];
            subvec{isub} = myvec;
            subacc{isub} = accvec;
            substim{isub} = stimvec;
            mymax = max([myvec mymax]);
            mymin = min([myvec mymin]);  
            
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
        fullsub(outliers) = [];
        fullimgt(outliers) = [];
        fullcond(outliers) = [];
        fullstim(outliers) = [];
        mymin = min(fullvec);
        mymax = max(fullvec);
        fullvec = (fullvec-mymin)/(mymax-mymin);
    end        
    
    condvec{icond+1} = fullvec;
    condacc{icond+1} = fullacc;
    
    if cfg.persub == 1
        n = nan(length(subvec),cfg.nbins);
        for isub = 1:length(subvec)
            if goodsubs(isub)
                mybins = linspace(mymin,mymax,cfg.nbins+1);                
                tempvec = subvec{isub};
                tempacc = subacc{isub};
                tempstim = substim{isub};
                if cfg.normalize
                    mybins = linspace(0,1,cfg.nbins+1);
                    outliers = tempvec>stdmax | tempvec<stdmin;
                    tempvec(outliers) = [];
                    tempacc(outliers) = [];
                    tempstim(outliers) = [];
                    tempvec = (tempvec-mymin) / (mymax-mymin);
                end
                subvec{isub} = tempvec;
                subacc{isub} = tempacc;
                substim{isub} = tempstim;
                [temp,whichbin] = histc(tempvec,mybins);
                n(isub,:) = temp(1:end-1);
                n(isub,end) = temp(end)+n(isub,end);
                interval = diff(mybins)./2;
                mybins = mybins(1:end-1)+interval;
                
                [b,dev,stats] = glmfit(tempvec,tempacc','binomial','link','logit');
                subb(isub,:) = b;
                if isub==1
                    substats = stats;
                else
                    substats(isub) = stats;
                end
                
                if cfg.dosubplots ==1             
                    [temp,whichbin] = histc(tempvec,mybins);
                    for ibin = 1:cfg.nbins
                        myacc(ibin) = mean(tempacc(whichbin==ibin));
                    end
                    xdata = linspace(min(tempvec),max(tempvec),100);
                    yfit = glmval(subb(isub,:)',xdata,'logit');
                    plot(xdata,yfit,'color',mycolors(isub,:));
                    plot(mybins,myacc,'.','color',mycolors(isub,:),'markersize',10)
                end
                                
                for ibin = 1:cfg.nbins
                    myacc(ibin) = mean(tempacc(whichbin==ibin));
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
        interval = diff(mybins)./2;
        mybins = mybins(1:end-1)+interval;
        [temp,whichbin] = histc(fullvec,mybins);
        n = temp(1:end-1);
        n(end) = temp(end)+n(end);
        myacc = [];
        myste = [];
        for ibin = 1:cfg.nbins
            myacc(ibin) = mean(fullacc(whichbin==ibin));
            myste(ibin) = ste(fullacc(whichbin==ibin));
        end
        [bfull,dev,stats] = glmfit(fullvec,fullacc','binomial','link','logit');        
    end
       
    if cfg.normalize == 1
        mymin = 0;
        mymax = 1;
    end
    
    if cfg.rmoutliers == 1 && cfg.persub==1
        thresmax = mean(subb) + std(subb)*3;
        thresmin = mean(subb) - std(subb)*3;
        thresind = subb(:,2)>thresmax(:,2) | subb(:,2)<thresmin(:,2);
        subb(thresind,:) = nan;
    end 
    
    if cfg.plotconds(icond+1)==1
        set(0,'CurrentFigure',h1);
        %interval = diff(mybins)./2;
        %mybins = mybins(1:end-1)+interval;
        xdata = linspace(mymin,mymax,100);
        if cfg.persub ==1
            if isfield(cfg,'mybeta')
                mybetas = cfg.mybeta;
            else
                mybetas = nanmean(subb)';
            end
            yfit = glmval(mybetas,xdata,'logit');
        else            
            yfit = glmval(bfull,xdata,'logit');
        end
        %plot(xdata,yfit,['-' lower(conds{icond+1}(1))]);
        errorbar(mybins,myacc,myste,['s' lower(conds{icond+1}(1))],'linewidth',2,'markersize',10,'markerfacecolor',lower(conds{icond+1}(1)));
        xlabel(cfg.vectype,'fontsize',20);
        ylabel('Accuracy','fontsize',20);
        box off
        set(gca,'fontsize',20);
        plot(xlim,[origacc(icond+1) origacc(icond+1)],['--' lower(conds{icond+1}(1))],'linewidth',.05);
    end
    
    outdata.(conds{icond+1}).bins = mybins;
    outdata.(conds{icond+1}).acc = myacc;
    outdata.(conds{icond+1}).ste = myste;
    outdata.(conds{icond+1}).subacc = subacc;
    outdata.(conds{icond+1}).subvec = subvec;
    outdata.(conds{icond+1}).substim = substim;
    outdata.(conds{icond+1}).X = fullvec;
    outdata.(conds{icond+1}).Y = fullacc;
    outdata.(conds{icond+1}).V = fullsub;
    outdata.(conds{icond+1}).imgt = fullimgt;
    outdata.(conds{icond+1}).cond = fullcond;
    outdata.(conds{icond+1}).stim = fullstim;
    outdata.(conds{icond+1}).n = n;
    if cfg.persub
        outdata.(conds{icond+1}).substats = substats;
        outdata.(conds{icond+1}).b = subb;
    else
        outdata.(conds{icond+1}).fullstats = stats;
        outdata.(conds{icond+1}).bfull = bfull;
    end
    
    [h,p,ci,stats] = ttest(subb);
    outdata.(conds{icond+1}).p = p;
    outdata.(conds{icond+1}).tstats = stats;

end
outdata.cfg = cfg;
switch cfg.imgt
    case 0
        tstr = 'Scenes only';
    case 1
        tstr = 'Faces only';
    case 2
        tstr = 'Scenes and Faces';
end
title(tstr,'fontsize',22);
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




