function [exper,newdata] = core_makeCombMemConds(cfg,adFile)
% creates condition split by remembered and forgotten trials, i.e. trials
% where subsequent memory was correct or incorrect
%
%   input:
%       cfg:
%           subjects = list of subject strings to process
%           eventValues = condition strings to process
%           savedata = bool 1=save 0=don't save
%       adFile = analisys details file to load 
%
%   output:
%       exper = new exper struct that has eventValues, trldata, and nTrials
%       updated
%       newdata = data structure with new 'Rem', and 'Forg' conditions
%


%% load AD
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails.mat';
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);
files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 150;

newexper = exper;
%% make new conditions
subjects = cfg.subjects;
conds = cfg.eventValues;

for isub = 1:length(cfg.subjects)
    %% load specific subject data
    subStr = subjects{isub};
    subNo = find(strcmp(subStr,exper.subjects));
    [experjnk,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile, subStr, cfg.eventValues);
    
    %% sort based on newtrldata
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
        newdata(icond).powspctrm = [];
        newdata(icond).trialinfo = [];
        newdata(icond).cumtapcnt = [];
        if isfield(newdata,'trialdata')
            newdata(icond).trialdata = [];
            newdata(icond).trialvars = [];
        end
    end
    newdata = newdata(1);
    incorrdata = newdata;
    condname = [];
    for icond = 1:length(conds)
        
        data = data_freq.(conds{icond}).sub(1).ses(1).data;
        trlinfo = exper.trldata(subNo).(conds{icond}).vals;
        vars = exper.trldata(subNo).(conds{icond}).vars;
        newdata.trialvars = vars;
        incorrdata.trialvars = vars;
        
        acccol = strcmp('acc',vars);
        trlncol = strcmp('trln',vars);
        
        if sum(acccol == 1) %must have an accuracy column in the trialdata
            
            %make sure trl numbers match up with trlinfo
            if ~(sum(data.trialinfo(:,2) == trlinfo(:,trlncol)) == size(trlinfo,1))
                error('Trial numbers don''t match between trldata and trlinfo');
            end
            
            %find correct vs incorrect memory trials
            corr = find(trlinfo(:,acccol)==1);
            incorr = find(trlinfo(:,acccol)==0);
            
            %combine corr trials
            newdata.powspctrm = cat(1,newdata.powspctrm,data.powspctrm(corr,:,:,:));
            newdata.trialinfo = cat(1,newdata.trialinfo,data.trialinfo(corr,:));
            newdata.cumtapcnt = cat(1,newdata.cumtapcnt,data.cumtapcnt(corr,:));
            newdata.trialdata = cat(1,newdata.trialdata,trlinfo(corr,:));
            
            %combine incorr trials
            incorrdata.powspctrm = cat(1,incorrdata.powspctrm,data.powspctrm(incorr,:,:,:));
            incorrdata.trialinfo = cat(1,incorrdata.trialinfo,data.trialinfo(incorr,:));
            incorrdata.cumtapcnt = cat(1,incorrdata.cumtapcnt,data.cumtapcnt(incorr,:));
            incorrdata.trialdata = cat(1,incorrdata.trialdata,trlinfo(incorr,:));
            
            condname = [condname conds{icond}(6:7)];               
            
        end
    end
    temp = tokenize(conds{icond},'_');   
    condname = [temp{1} '_' condname sprintf('_%s',temp{3:end})];
    newexper.eventValuesExtra.(condname) = conds;
    
    %make Rem conditions in exper
    idx = strcmp([condname '_Rem'],newexper.eventValues);
    if sum(idx)==0
        newexper.eventValues{end+1} = [condname '_Rem'];
        newexper.nTrials.([condname '_Rem']) = nan(size(newexper.nTrials.(conds{1})));
        newexper.nTrials.([condname '_Rem'])(subNo) = size(newdata.trialinfo,1);
        newexper.trldata(subNo).([condname '_Rem']).vals = newdata.trialdata;
        newexper.trldata(subNo).([condname '_Rem']).vars = vars;
    else
        newexper.nTrials.([condname '_Rem'])(subNo) = size(newdata.trialinfo,1);
        newexper.trldata(subNo).([condname '_Rem']).vals = newdata.trialdata;
        newexper.trldata(subNo).([condname '_Rem']).vars = vars;
    end
    fprintf('Creating condition %s with %d trials for subject %s\n',[condname '_Rem'],newexper.nTrials.([condname '_Rem'])(subNo),subStr);
    
    %make Forg conditions in exper
    idx = strcmp([condname '_Forg'],newexper.eventValues);
    if sum(idx)==0
        newexper.eventValues{end+1} = [condname '_Forg'];
        newexper.nTrials.([condname '_Forg']) = nan(size(newexper.nTrials.(conds{1})));
        newexper.nTrials.([condname '_Forg'])(subNo) = size(incorrdata.trialinfo,1);
        newexper.trldata(subNo).([condname '_Forg']).vals = incorrdata.trialdata;
        newexper.trldata(subNo).([condname '_Forg']).vars = vars;
    else
        newexper.nTrials.([condname '_Forg'])(subNo) = size(incorrdata.trialinfo,1);
        newexper.trldata(subNo).([condname '_Forg']).vals = incorrdata.trialdata;
        newexper.trldata(subNo).([condname '_Forg']).vars = vars;
    end
    fprintf('Creating condition %s with %d trials for subject %s\n',[condname '_Forg'],newexper.nTrials.([condname '_Forg'])(subNo),subStr);
       
    %% save new condition data
    if cfg.savedata ==1
            
            %save corr data
            savedir = fullfile(dirs.saveDirProc,subStr,'ses1');
            savefile = fullfile(savedir, ['data_pow_' condname '_Rem.mat']);
            fprintf('Saving new condition %s_Rem for subject %s to file:\n%s\n...',condname,subStr,savefile);
            freq = newdata;
            save(savefile,'freq');
            fprintf('Done\n');
            
            %save incorr data
            savefile = fullfile(savedir, ['data_pow_' condname '_Forg.mat']);
            fprintf('Saving new condition %s_Forg for subject %s to file:\n%s\n...',condname,subStr,savefile);
            freq = incorrdata;
            save(savefile,'freq');
            fprintf('Done\n');

    end
end
exper = newexper;




