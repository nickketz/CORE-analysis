function nk_ft_makeavgclusplots(cfg_ft,cfg_plot,dirs,files,data_freq,stat_clus)
%% make average plot for significant elecs


vsstr = fieldnames(stat_clus);

for iclus = 1:length(stat_clus.(vsstr{1}).posclusters)
    if stat_clus.(vsstr{1}).posclusters(iclus).prob < cfg_ft.alpha
        fprintf('***\n***\nSignficant cluster found for %s\n',vsstr{1});
        cfg_ft.clusnum = iclus;
        outdata = nk_ft_avgclustplot(stat_clus,cfg_plot,cfg_ft,dirs,files,files.saveFigs);        
        % plot cluster average power over time  
        outdata = nk_ft_avgpowerbytime(data_freq,stat_clus,cfg_plot,cfg_ft,dirs,files,files.saveFigs);
        %outdatafreq = nk_ft_avgpowerbyfreq(data_freq,stat_clus,cfg_plot,cfg_ft,dirs,files,1);
    else
        continue;
    end
end
