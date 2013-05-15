function [exper,newdata] = core_makeSwitchConds(cfg,adFile)


%% load AD
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails.mat';
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);
files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 150;

% create 'succ' vector
exper.trldata = core_getsuccvec(exper);
newexper = exper;
%% make new conditions
subjects = cfg.subjects;
for isub = 1:length(cfg.subjects)
    %% load specific subject data
    subStr = subjects{isub};
    [experjnk,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile, subStr, cfg.eventValues);
    
    %% sort based on newtrldata
    conds = ana.eventValues{1};
    %make new data struct
    for icond = 1:length(conds)
        if icond == 1
            newdata = data_freq.(conds{icond}).sub(1).ses(1).data;
        else
            newdata(icond) = data_freq.(conds{icond}).sub(1).ses(1).data;
        end
        newdata(icond).powspctrm = [];
        newdata(icond).trialinfo = [];
        newdata(icond).cumtapcnt = [];
    end
    newdata(icond).trialdata = [];
    newdata(icond).trialvars = [];
    
    subNo = find(strcmp(subStr,exper.subjects));
    
    for icond = 1:length(conds)
        if strfind(conds{icond}, 'Word')
            data = data_freq.(conds{icond}).sub(1).ses(1).data;
            trlinfo = exper.trldata(subNo).(conds{icond}).vals;
            vars = exper.trldata(subNo).(conds{icond}).vars;
            newdata(icond).trialvars = vars;
            
            condcol = strcmp('cond',vars);
            stimcol = strcmp('stim',vars);
            trlncol = strcmp('trln',vars);
            imgtcol = strcmp('imgt',vars);
            succcol = strcmp('succ',vars);
            
            temp = tokenize(conds{icond},'_');
            condnum = [0 1 2];
            mycond = condnum(strcmp(temp{2},{'Green','Blue','Red'}));
            
            %make sure trl numbers match up with trlinfo
            if ~(sum(data.trialinfo(:,2) == trlinfo(:,trlncol)) == size(trlinfo,1))
                error('Trial numbers don''t match between trldata and trlinfo');
            end
            
            %grab all trials from this cond and put in newdata
            if mycond == 1 || mycond== 2
                samecond = find(trlinfo(:,succcol) == 1);
                diffcond = find(trlinfo(:,succcol) == 0);
            elseif mycond == 0 %no change for green
                samecond = 1:size(trlinfo,1);
                diffcond = [];
            end
                       
            
            newdata(icond).powspctrm = cat(1,newdata(icond).powspctrm,data.powspctrm(samecond,:,:,:));
            newdata(icond).trialinfo = cat(1,newdata(icond).trialinfo,data.trialinfo(samecond,:));
            newdata(icond).cumtapcnt = cat(1,newdata(icond).cumtapcnt,data.cumtapcnt(samecond,:));
            newdata(icond).trialdata = cat(1,newdata(icond).trialdata,trlinfo(samecond,:));
            
            %find changing conditions and move data into appropriate new cond
            if ~isempty(diffcond)
                switch mycond
                    case 2
                        % replace color word with 'Blue'
                        temp{2} = 'Blue';
                    case 1
                        % replace color word with 'Red'
                        temp{2} = 'Red';
                    otherwise
                        error('condition number not recognized');
                end
                temp = [temp{1} '_' temp{2} '_' temp{3}];
                condind = find(strcmp(temp,conds));
                newdata(condind).powspctrm = cat(1,newdata(condind).powspctrm,data.powspctrm(diffcond,:,:,:));
                newdata(condind).trialinfo = cat(1,newdata(condind).trialinfo,data.trialinfo(diffcond,:));
                newdata(condind).cumtapcnt = cat(1,newdata(condind).cumtapcnt,data.cumtapcnt(diffcond,:));
                newdata(condind).trialdata = cat(1,newdata(condind).trialdata,trlinfo(diffcond,:));
            end           
        end
    end
    for icond = 1:length(conds)
        %make new condition in exper
        idx = strcmp([conds{icond} '_Switch'],newexper.eventValues);
        if sum(idx)==0
            newexper.eventValues{end+1} = [conds{icond} '_Switch'];
            newexper.nTrials.([conds{icond} '_Switch']) = nan(size(newexper.nTrials.(conds{icond})));
            newexper.nTrials.([conds{icond} '_Switch'])(subNo) = size(newdata(icond).trialinfo,1);
            newexper.trldata(subNo).([conds{icond} '_Switch']).vals = newdata(icond).trialdata;
            newexper.trldata(subNo).([conds{icond} '_Switch']).vars = vars;
        else
            newexper.nTrials.([conds{icond} '_Switch'])(subNo) = size(newdata(icond).trialinfo,1);
            newexper.trldata(subNo).([conds{icond} '_Switch']).vals = newdata(icond).trialdata;
            newexper.trldata(subNo).([conds{icond} '_Switch']).vars = vars;
        end
    end
    
    %% save new condition data
    if cfg.savedata ==1
        for icond = 1:length(conds)
            data = newdata(icond);
            if ~isempty(data.powspctrm)
                %new data exists
                savedir = fullfile(dirs.saveDirProc,subStr,'ses1');
                savefile = fullfile(savedir, ['data_pow_' conds{icond} '_Switch.mat']);
                fprintf('Saving new condition %s for subject %s to file:\n%s\n...',conds{icond},subStr,savefile);
                freq = newdata(icond);
                save(savefile,'freq');
                fprintf('Done\n');
            end
        end
    end
end
exper = newexper;




