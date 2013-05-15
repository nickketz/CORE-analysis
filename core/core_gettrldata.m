function [trldata,evt] = core_gettrldata(data_freq,dirs,exper,sub)

evt = struct();
trldata = struct();
dirs.behav = fullfile(dirs.dataroot, dirs.saveDirStem, 'ses1', 'behav');
%match up trialinfo trial numbers to evt trial numbers
subNo = sub;
sub = exper.subjects{sub};


evtdir = fullfile(dirs.dataroot, dirs.saveDirStem, 'ses1','ns_evt');
evtfiles = dir([evtdir filesep sub '*.evt']);
if length(evtfiles)==1
    evt = readevt([evtdir filesep evtfiles(1).name],exper.sampleRate);
    evt = core_filtevt(evt);
else
    error('multiple matching event files found');
end

%load behavioral data to get subsequent memory
behav_fname = ['CORE_acc2_subj' sub(end-1:end) '.mat'];
load([dirs.behav filesep behav_fname],'stimmat','acc_cor'); %must have acc cor run already
if ~exist('acc_cor','var')
    error('no corrected accuracy vector found in %s\n',behav_fname);
end

fnames = fieldnames(data_freq);
for iconds = 1:length(fnames)
    conddata = [];
    tempdata = data_freq.(fnames{iconds});
    trln = tempdata.trialinfo(:,2);
    evttrl = evt.(fnames{iconds}).vals(:,2);
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

trldata = tempstruct;

