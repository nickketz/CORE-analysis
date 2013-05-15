function [exper,newdata] = core_makeHalfConds(cfg,adFile)


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
    
    second = newdata;
    
    subNo = find(strcmp(subStr,exper.subjects));
    
    for icond = 1:length(conds)
        
        data = data_freq.(conds{icond}).sub(1).ses(1).data;
        trlinfo = exper.trldata(subNo).(conds{icond}).vals;
        vars = exper.trldata(subNo).(conds{icond}).vars;
        newdata(icond).trialvars = vars;
        second(icond).trialvars = vars;
        
        repcol = strmp('rep',vars);
        if sum(repcol == 1) %must have a repetition column in the trialdata
            
            %make sure trl numbers match up with trlinfo
            if ~(sum(data.trialinfo(:,2) == trlinfo(:,trlncol)) == size(trlinfo,1))
                error('Trial numbers don''t match between trldata and trlinfo');
            end
            
            %find first-half vs second-half trials
            first = find(trlinfo(:,repcol)<=5);
            second = find(trlinfo(:,repcol)>5);
            
            %combine first-half trials
            newdata(icond).powspctrm = cat(1,newdata(icond).powspctrm,data.powspctrm(first,:,:,:));
            newdata(icond).trialinfo = cat(1,newdata(icond).trialinfo,data.trialinfo(first,:));
            newdata(icond).cumtapcnt = cat(1,newdata(icond).cumtapcnt,data.cumtapcnt(first,:));
            newdata(icond).trialdata = cat(1,newdata(icond).trialdata,trlinfo(first,:));
            
            %combine second-half trials
            second(icond).powspctrm = cat(1,second(icond).powspctrm,data.powspctrm(second,:,:,:));
            second(icond).trialinfo = cat(1,second(icond).trialinfo,data.trialinfo(second,:));
            second(icond).cumtapcnt = cat(1,second(icond).cumtapcnt,data.cumtapcnt(second,:));
            second(icond).trialdata = cat(1,second(icond).trialdata,trlinfo(second,:));
            
            %make 1of2 conditions in exper
            idx = strcmp([conds{icond} '_1of2'],newexper.eventValues);
            if sum(idx)==0
                newexper.eventValues{end+1} = [conds{icond} '_1of2'];
                newexper.nTrials.([conds{icond} '_1of2']) = nan(size(newexper.nTrials.(conds{icond})));
                newexper.nTrials.([conds{icond} '_1of2'])(subNo) = size(newdata(icond).trialinfo,1);
                newexper.trldata(subNo).([conds{icond} '_1of2']).vals = newdata(icond).trialdata;
                newexper.trldata(subNo).([conds{icond} '_1of2']).vars = vars;
            else
                newexper.nTrials.([conds{icond} '_1of2'])(subNo) = size(newdata(icond).trialinfo,1);
                newexper.trldata(subNo).([conds{icond} '_1of2']).vals = newdata(icond).trialdata;
                newexper.trldata(subNo).([conds{icond} '_1of2']).vars = vars;
            end
            
            %make 2of2 conditions in exper
            idx = strcmp([conds{icond} '_2of2'],newexper.eventValues);
            if sum(idx)==0
                newexper.eventValues{end+1} = [conds{icond} '_2of2'];
                newexper.nTrials.([conds{icond} '_2of2']) = nan(size(newexper.nTrials.(conds{icond})));
                newexper.nTrials.([conds{icond} '_2of2'])(subNo) = size(second(icond).trialinfo,1);
                newexper.trldata(subNo).([conds{icond} '_2of2']).vals = second(icond).trialdata;
                newexper.trldata(subNo).([conds{icond} '_2of2']).vars = vars;
            else
                newexper.nTrials.([conds{icond} '_2of2'])(subNo) = size(second(icond).trialinfo,1);
                newexper.trldata(subNo).([conds{icond} '_2of2']).vals = second(icond).trialdata;
                newexper.trldata(subNo).([conds{icond} '_2of2']).vars = vars;
            end
            
        end
    end
    
    %% save new condition data
    if cfg.savedata ==1
        for icond = 1:length(conds)
            data = newdata(icond);
            seconddata = second(icond);
            if ~isempty(data.powspctrm) && ~isempty(seconddata.powspctrm)
                %save first-half data
                savedir = fullfile(dirs.saveDirProc,subStr,'ses1');
                savefile = fullfile(savedir, ['data_pow_' conds{icond} '_1of2.mat']);
                fprintf('Saving new condition %s_1of2 for subject %s to file:\n%s\n...',conds{icond},subStr,savefile);
                freq = newdata(icond);
                save(savefile,'freq');
                fprintf('Done\n');
                
                %save second data
                savefile = fullfile(savedir, ['data_pow_' conds{icond} '_2of2.mat']);
                fprintf('Saving new condition %s_2of2 for subject %s to file:\n%s\n...',conds{icond},subStr,savefile);
                freq = seconddata(icond);
                save(savefile,'freq');
                fprintf('Done\n');
                
            end
        end
    end
end
exper = newexper;




