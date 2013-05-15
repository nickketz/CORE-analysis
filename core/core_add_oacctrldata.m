function [trldata] = core_add_oacctrldata(exper,ana,dirs)

trldata = exper.trldata;

%add orig acc to trldata
conds = ana.eventValues{1};

for isub = 1:length(exper.subjects)
    for icond = 1:length(conds)
        
        vars = exper.trldata(isub).(conds{icond}).vars;
        vals = exper.trldata(isub).(conds{icond}).vals;
        
        stimcol = strcmp(vars,'stim');
        stims = unique(vals(:,stimcol));
        
        behavdir = fullfile(dirs.dataroot,dirs.dataDir,'ses1','behav');
        bfile = [behavdir filesep 'CORE_' exper.subjects{isub}(end-1:end) '_0.dat'];
        indata = core_datread(bfile);

        oacc = nan(size(vals,1),1);
        for istim = 1:length(stims)
            stimidx = indata.stim == stims(istim);
            valsstimidx = vals(:,stimcol)==stims(istim);
%             if sum(stimidx) ~=1
%                 error('multiple stim matches');
%             end
            oacc(valsstimidx) = indata.acc(stimidx);
        end
        trldata(isub).(conds{icond}).vals = [vals oacc];
        trldata(isub).(conds{icond}).vars = {vars{:}, 'oacc'};
        
    end
end
