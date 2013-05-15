function [trldata,evt] = core_seg_gettrldata(cfg,ana,dirs,exper)

evt = cfg.evt;%struct();
trldata = struct();
dirs.behav = fullfile(dirs.dataroot, dirs.saveDirStem, 'ses1', 'behav');
%match up trialinfo trial numbers to evt trial numbers
for isub = 1:length(exper.subjects)
    sub = exper.subjects{isub};
    
    evtdir = fullfile(dirs.dataroot, dirs.saveDirStem, 'ses1','ns_evt');
    evtfiles = dir([evtdir filesep sub '*.evt']);
    if length(evtfiles)==1
        if isub == 1
            evt = readevt([evtdir filesep evtfiles(1).name],exper.sampleRate);
        else
            evt(isub) = readevt([evtdir filesep evtfiles(1).name],exper.sampleRate);
        end
        evt(isub) = core_filtevt(evt(isub));
    else
        error('multiple matching event files found');
    end
    
    %load behavioral data to get subsequent memory
    behav_fname = ['CORE_acc2_subj' sub(end-1:end) '.mat'];
    load([dirs.behav filesep behav_fname],'stimmat','acc_cor'); %must have acc cor run already
    if ~exist('acc_cor','var')
        error('no corrected accuracy vector found in %s\n',behav_fname);
    end
    
    fnames = ana.eventValues{1};
    for iconds = 1:length(fnames)
        conddata = [];
        tempdata = data_freq.(fnames{iconds}).sub(isub).ses(1).data;
        trln = tempdata.trialinfo(:,2);
        evttrl = evt(isub).(fnames{iconds}).vals(:,2);
        tidx = zeros(size(trln));
        for itrl = 1:length(trln)
            tempidx = find(trln(itrl)==evttrl);
            if length(tempidx)>1
                error('multiple matching trial numbers in evt struct');
            else
                tidx(itrl) = tempidx;
            end
            conddata(itrl,1:size(evt.(fnames{iconds}).vals,2)) = evt.(fnames{iconds}).vals(tidx(itrl),:);
        end
        tempstruct.(fnames{iconds}).vals = conddata;
        tempstruct.(fnames{iconds}).vars = evt.(fnames{iconds}).vars;
        if ismember('stim',tempstruct.(fnames{iconds}).vars)
            stimidx = strcmp('stim',tempstruct.(fnames{iconds}).vars);
            tempstruct.(fnames{iconds}).vals(:,end+1) = acc_cor(tempstruct.(fnames{iconds}).vals(:,stimidx));
            tempstruct.(fnames{iconds}).vars{end+1} = 'acc';
        end
    end
    if isub == 1
        trldata = tempstruct;
    else
        trldata(isub) = tempstruct;
    end
    
end
