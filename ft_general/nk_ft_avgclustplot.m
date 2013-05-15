function outdata = nk_ft_avgclustplot(stat_clus,cfg_plot,cfg_ft,dirs,files,savefigs)

if ~isempty(savefigs)
    files.saveFigs = 1;
end
    
vsstr = fieldnames(stat_clus);%[cfg.conds{1} 'vs' cfg.conds{2}];

ind = find(stat_clus.(vsstr{1}).posclusterslabelmat==cfg_ft.clusnum);
[x,y,z] = ind2sub(size(stat_clus.(vsstr{1}).posclusterslabelmat),ind);
elecs = stat_clus.(vsstr{1}).label(unique(x));
elecnums = unique(x);

tvals = zeros(length(stat_clus.(vsstr{1}).label),1,1);
for i = 1:length(elecnums)
    ind = find(x==elecnums(i));
    tempdata = [];
    for j = 1:length(ind)
        tempdata(j) = stat_clus.(vsstr{1}).stat(x(ind(j)),y(ind(j)),z(ind(j)));
    end
    tvals(elecnums(i)) = mean(tempdata);
end

load('dummy1dclus.mat');
%new_clus = stat_clus.(vsstr{1});
new_clus.stat = tvals;
new_clus.prob = tvals;
new_clus.label = stat_clus.(vsstr{1}).label;
lmat = zeros(size(tvals));
lmat(elecnums) = 1;
new_clus.posclusterslabelmat = lmat;
new_clus.posclusters = stat_clus.(vsstr{1}).posclusters;
cfg_ft.highlightcolorpos = [1 1 1];
ft_clusterplot(cfg_ft,new_clus);
colorbar;
title([regexprep(vsstr{1},'_','') ', Cluster ' num2str(cfg_ft.clusnum) ', p=' num2str(stat_clus.(vsstr{1}).posclusters(cfg_ft.clusnum).prob)],'fontsize',20);
outdata = tvals;

if ~isfield(cfg_plot,'dirStr')
    cfg_plot.dirStr = '';
end
p = stat_clus.(vsstr{1}).posclusters(cfg_ft.clusnum).prob;
if files.saveFigs
%     fignums = findobj('Type','figure');
%     for f = 1:length(fignums)
%         figure(f)
        f = cfg_ft.clusnum;
        cfg_plot.figfilename = sprintf('tfr_clus_avgclus_%s_%d_%d_%d_%d_%f_fig%d',vsstr{1},round(cfg_plot.frequency(1)),round(cfg_plot.frequency(2)),round(cfg_plot.latency(1)*1000),round(cfg_plot.latency(2)*1000),p,f);
        
        dirs.saveDirFigsClus = fullfile(dirs.saveDirFigs,sprintf('tfr_stat_clus_%d_%d%s',round(cfg_plot.latency(1)*1000),round(cfg_plot.latency(2)*1000),cfg_plot.dirStr),vsstr{1});
        if ~exist(dirs.saveDirFigsClus,'dir')
            mkdir(dirs.saveDirFigsClus)
        end
        
        while exist([fullfile(dirs.saveDirFigsClus,cfg_plot.figfilename) '.' files.figPrintFormat],'file')
            f=f+1;
            cfg_plot.figfilename = sprintf('tfr_clus_avgclus_%s_%d_%d_%d_%d_fig%d',vsstr{1},round(cfg_plot.frequency(1)),round(cfg_plot.frequency(2)),round(cfg_plot.latency(1)*1000),round(cfg_plot.latency(2)*1000),f);
        end
        if strcmp(files.figPrintFormat,'fig')
            saveas(gcf,fullfile(dirs.saveDirFigsClus,[cfg_plot.figfilename '.' files.figPrintFormat]),'fig');
        else
            if strcmp(files.figPrintFormat(1:2),'-d')
                files.figPrintFormat = files.figPrintFormat(3:end);
            end
            if ~isfield(files,'figPrintRes')
                files.figPrintRes = 150;
            end
            set(gcf,'InvertHardCopy','off');
            set(gcf,'Color','White');
            print(gcf,sprintf('-%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigsClus,[cfg_plot.figfilename '.' files.figPrintFormat]));
        end
end % if
