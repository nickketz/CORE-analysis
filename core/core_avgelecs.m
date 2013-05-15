function outdata = core_avgelecs(cfg,ana,data_freq)

% average electrode freq data across channels
%
% input: 
%   cfg: cfg struct with fields
%       grpavg: roi names to average
%
%   ana: analysis struct with elecGroup fields (elecGroups, and
%   elecGroupsStr)
%   
%   data_freq: freq data struct for single subject
%
% output:
%   outdata: freq struct with new averaged elec groups
%


%find chan in dimorder
conds = ana.eventValues{1};
outdata = data_freq;
for icond = 1:length(conds)
    outdata.(conds{icond}).sub.ses.data.powspctrm = [];
    outdata.(conds{icond}).sub.ses.data.label = {};
    fprintf('Averaging in cond %s...\n', conds{icond});
    for igrp = 1:length(cfg.grpavg)
        temp = ft_selectdata(data_freq.(conds{icond}).sub.ses.data,'chan',cfg.grpavg{igrp},'avgoverchan','yes','param','powspctrm');
        cat(2,temp,outdata.(conds{icond}).sub.ses.data.powspctrm);
        outdata.(conds{icond}).sub.ses.data.label{end+1} = cfg.grpavg{igrp};
    end
    
end