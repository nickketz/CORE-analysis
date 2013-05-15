function [data_freq] = nk_ft_baselinecorrect(data_freq,ana,exper,cfg)
% run baseline correction on time frequency subject data
%
%   input:
%       ana = analysis structure
%       exper = experiment structure
%       cfg = config structure including:
%           .baseline = 1x2 float, time window to average over ['no']
%           .baselinetype = str, ['absolute']
%
%   output:
%       outdata = freq data in subject structure
%


% Change in freq relative to baseline using absolute power
if exist('cfg','var')
    cfg_fb = cfg;
else
    cfg_fb = [];
end

for sub = 1:length(exper.subjects)
    if exper.badSub(sub)
        fprintf('Skipping bad subject %s\n',exper.subjects{sub})
    else
        for ses = 1:length(exper.sessions)
            for typ = 1:length(ana.eventValues)
                for evVal = 1:length(ana.eventValues{typ})
                    fprintf('%s, %s, %s, ',exper.subjects{sub},exper.sessions{ses},ana.eventValues{typ}{evVal});
                    data_freq.(ana.eventValues{typ}{evVal}).sub(sub).ses(ses).data = ft_freqbaseline(cfg_fb,data_freq.(ana.eventValues{typ}{evVal}).sub(sub).ses(ses).data);
                end
            end
        end
    end
end
