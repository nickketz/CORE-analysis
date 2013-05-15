function [exper,newdata] = core_makeCombConds(cfg,adFile)

if ~isfield(cfg,'param')
    cfg.param = 'powspctrm';
end

%% load AD
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);
files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 300;
newexper = exper;

subjects = cfg.subjects;
for isub = 1:length(cfg.subjects)
    
    %% load specific subject data
    subStr = subjects{isub};
    subNo = find(strcmp(subStr,exper.subjects));
    [experjnk,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile, subStr, cfg.datatype, cfg.eventValues);
    
    %% sort based on newtrldata
    conds = ana.eventValues{1};
    newconds = conds;
    %make new data struct
    for icond = 1:length(conds)
        if icond == 1
            if exper.nTrials.(conds{icond})(subNo) > 0
                newdata = data_freq.(conds{icond}).sub(1).ses(1).data;
            else
                fprintf('Warning: condition %s has 0 trials!!\n',conds{icond});
                inext = 0;
                while exper.nTrials.(conds{icond+inext})(subNo) < 1
                    inext = inext+1;                    
                end
                newdata = data_freq.(conds{icond+inext}).sub(1).ses(1).data;
            end
        else
            if exper.nTrials.(conds{icond})(subNo) > 0
                newdata(icond) = data_freq.(conds{icond}).sub(1).ses(1).data;
            else
                newdata(icond) = newdata(icond-1);
            end
        end
        newdata(icond).(cfg.param) = [];
        newdata(icond).trialinfo = [];
        newdata(icond).cumtapcnt = [];
        if isfield(newdata,'trialdata')
            newdata(icond).trialdata = [];
            newdata(icond).trialvars = [];
        end
        
        temp = tokenize(conds{icond},'_');
        cndidx = strcmp(temp,'Face') | strcmp(temp,'Scene');
        if sum(cndidx) == 1
            temp{cndidx} = 'Comb';
            temp = sprintf('%s_',temp{:});
            temp = temp(1:end-1);
        end
        newconds{icond} = temp;
    end
    newconds = unique(newconds);
    newdata = newdata(1:length(newconds));
    
    if ~isfield(newdata,'trialdata')
        newdata(end).trialdata = [];
        newdata(end).trialvars = [];
    end
    
    
    subNo = find(strcmp(subStr,exper.subjects));
    
    for icond = 1:length(conds)
        if isfield(data_freq.(conds{icond}).sub(1).ses(1).data,cfg.param) %skip conditions with no trials            
            temp = tokenize(conds{icond},'_');            
            if sum(strcmp(temp{2},{'Green','Blue','Red'}))>0
                condnum = [0 1 2];
                mycond = condnum(strcmp(temp{2},{'Green','Blue','Red'}));
                cndidx = strcmp(temp,'Face') | strcmp(temp,'Scene');
                if sum(cndidx)~=1
                    error('missing of multiple Face or Scene labels in condition string');
                end
                temp{cndidx} = 'Comb';
                newcondstr = sprintf('%s_',temp{:});
                newcondstr = newcondstr(1:end-1);
                condind = strcmp(newcondstr,newconds);
                
                data = data_freq.(conds{icond}).sub(1).ses(1).data;
                trlinfo = exper.trldata(subNo).(conds{icond}).vals;
                vars = exper.trldata(subNo).(conds{icond}).vars;
                
                newdata(condind).trialvars = vars;
                
                condcol = strcmp('cond',vars);
                stimcol = strcmp('stim',vars);
                trlncol = strcmp('trln',vars);
                imgtcol = strcmp('imgt',vars);
                
                %make sure trl numbers match up with trlinfo
                if ~(sum(data.trialinfo(:,2) == trlinfo(:,trlncol)) == size(trlinfo,1))
                    error('Trial numbers don''t match between trldata and trlinfo');
                end
                
                newdata(condind).(cfg.param) = cat(1,newdata(condind).(cfg.param),data.(cfg.param));
                newdata(condind).trialinfo = cat(1,newdata(condind).trialinfo,data.trialinfo);
                newdata(condind).cumtapcnt = cat(1,newdata(condind).cumtapcnt,data.cumtapcnt);
                newdata(condind).trialdata = cat(1,newdata(condind).trialdata,trlinfo);
            end
        else
            fprintf('No trials found in condition %s, for subject %s\n',conds{icond},subStr);            
        end
    end
    for icond = 1:length(newconds)
        %make new condition in exper
        idx = strcmp(newconds{icond},newexper.eventValues);
        if sum(idx)==0
            newexper.eventValues{end+1} = newconds{icond};
            newexper.nTrials.(newconds{icond}) = nan(size(newexper.nTrials.(conds{icond})));
            newexper.nTrials.(newconds{icond})(subNo) = size(newdata(icond).trialinfo,1);
            newexper.trldata(subNo).(newconds{icond}).vals = newdata(icond).trialdata;
            newexper.trldata(subNo).(newconds{icond}).vars = vars;
        else
            newexper.nTrials.(newconds{icond})(subNo) = size(newdata(icond).trialinfo,1);
            newexper.trldata(subNo).(newconds{icond}).vals = newdata(icond).trialdata;
            newexper.trldata(subNo).(newconds{icond}).vars = vars;
        end
        fprintf('Creating condition %s with %d trials for subject %s\n',newconds{icond},newexper.nTrials.(newconds{icond})(subNo),subStr);
    end
    fprintf('\n');
    
    %% save new condition data
    if cfg.savedata ==1
        for icond = 1:length(newconds)
            data = newdata(icond);
            if ~isempty(data.(cfg.param))
                %new data exists
                savedir = fullfile(dirs.saveDirProc,subStr,'ses1');
                savefile = fullfile(savedir, ['data_' cfg.datatype '_' newconds{icond} '.mat']);
                fprintf('Saving new condition %s for subject %s to file:\n%s\n...',newconds{icond},subStr,savefile);
                freq = newdata(icond);
                save(savefile,'freq');
                fprintf('Done\n');
            end
        end
    end
end
exper = newexper;



