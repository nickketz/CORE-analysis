function outdata = core_acceval(cfg,exper)

cfg.congcrit = .5;
[jnk, substruct] = core_getbehavmeas(exper,cfg);
conds = {'Green','Blue','Red','k'};
figure('color','white')
hold on

for icond = 0:3
    accvec = [];
    myvec = [];
    
    for isub = 1:length(substruct)        
        if icond == 3
            ind = substruct(isub).cond>-1;
        else
            ind = substruct(isub).cond==icond;
        end
        if exper.trainresult(isub).bi < .05 || cfg.dofilt == 0
            accvec = [accvec substruct(isub).acc(ind)];
            
            switch cfg.vectype 
                case 'congdiff'
                    myvec = [myvec [substruct(isub).cong(ind) - substruct(isub).incong(ind)]];
                case 'pct'
                    myvec = [myvec substruct(isub).pctcong(ind)];
                case 'cong'
                    myvec = [myvec substruct(isub).cong(ind)];
                case 'incong'
                    myvec = [myvec substruct(isub).incong(ind)];
                otherwise
                    error('unrecognized vector type');
            end
        end
    end
    
    mybins = unique(myvec);    
    myacc = arrayfun(@(x)(mean(accvec(myvec==x))),mybins);
    
    plot(mybins,myacc,['s--' lower(conds{icond+1}(1))],'linewidth',1,'markersize',10,'markerfacecolor',lower(conds{icond+1}(1)))
    xlabel(cfg.vectype);
    ylabel('Accuracy');
    box off
    set(gca,'fontsize',16);
    ylim([0 1]);
    
    outdata.(conds{icond+1}).bins = mybins;
    outdata.(conds{icond+1}).acc = myacc;

end
outdata.cfg = cfg;
legend({'Green','Blue','Red','Blue and Red'},'Location','Best');
