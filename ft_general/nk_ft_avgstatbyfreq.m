function [outdata] = nk_ft_avgstatbyfreq(freqdata,stat_clus,cfg)

% create a 2d power as a function of freq plot for selected electrodes,
% frequencies, and conditions
% 
% input
%   freqdata = power data for individual subjects
%   cfg = plot specifications 
%       cfg.freq = freq points to display
%       cfg.freq = frequencies average over
%       cfg.elecs = cell array of electrodes to average over
%       cfg.conds = cell array of conditions names to display
% 
% output 
%   outdata = avgerage data plotted

if ~isfield(cfg,'transp')
    cfg.transp = 0;
end
vsstr = fieldnames(stat_clus);
vsstr = vsstr{1};

ind = find(stat_clus.(vsstr).posclusterslabelmat==cfg.clusnum);
[x,y,z] = ind2sub(size(stat_clus.(vsstr).posclusterslabelmat),ind);
elecs = stat_clus.(vsstr).label(unique(x));
sigt = stat_clus.(vsstr).time(unique(z));
sigf = stat_clus.(vsstr).freq(unique(y));
cfg.freq = stat_clus.(vsstr).cfg.frequency;%cfg_ana.frequencies;%[8 12];

cfg.elecs = {};
for i = 1:length(elecs)
        cfg.elecs = cat(2,cfg.elecs,elecs{i});
end

cfg.sigt = sigt;


%make condition average data matrix across subjects
conddata = nan(length(stat_clus.(vsstr).freq),length(cfg.conds));
for icond = 1:length(cfg.conds)
    inconds = fieldnames(freqdata);
    condidx = strcmp(inconds,cfg.conds{icond});
    if sum(condidx) ~= 1
        error('nonexistant or nonunique condition name');
    else
        cond = inconds{condidx};
    end
    data = stat_clus.(vsstr).stat;
    data = sum(data,3);
    data = squeeze(sum(data,1));        
    conddata(:,icond) = data;
end


figure('color','white');
colors = get(gca,'ColorOrd');
for i = 1:size(data.data,2)
    h = shadedErrorBar(outdata.freq,outdata.data(:,i),outdata.var(:,i),{'color',colors(i,:),'linewidth',5},cfg.transp);
    lh(i) = h.mainLine;
    hold on
end

set(gca,'fontsize',22);
xlim([-.5,max(data.freq)]);
xlabel('Freq(Hz)');
ylabel('Power');
%outdata.conds{3} = 'pB';outdata.conds{2} = 'T';
legend(lh,outdata.conds,'location','best','fontsize',10);
title(sprintf('%s',['Cluster ' num2str(cfg.clusnum) ', AvgPwr' num2str(cfg.freq(1)) 'to' num2str(cfg.freq(2)) 'Hz']));
if isfield(cfg,'sigt')
    plot(repmat(min(cfg.sigt),2,1),ylim,'--k','linewidth',3);
    hold on
    plot(repmat(max(cfg.sigt),2,1),ylim,'--k','linewidth',3);
end

box off



        
        
    




