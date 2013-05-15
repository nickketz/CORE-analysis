function [mydata,cols] = core_add_oacc(mydata,cols,dirs,exper)

%add orig acc to mydata

fulloacc = nan(size(mydata,1),1);
oaccidx = 0;
subcol = strcmp(cols,'subn');
stimcol = strcmp(cols,'stimn');
for isub = 1:length(exper.subjects)    
    
    behavdir = fullfile(dirs.dataroot,dirs.dataDir,'ses1','behav');
    bfile = [behavdir filesep 'CORE_' exper.subjects{isub}(end-1:end) '_0.dat'];
    indata = core_datread(bfile);
    
    subidx = mydata(:,subcol)==isub;
    stims = mydata(subidx,stimcol);
    oacc = nan(length(stims),1);
    for istim = 1:length(stims)
        stimidx = indata.stim == stims(istim);
        if sum(stimidx) ~=1
            error('multiple stim matches');
        end            
        oacc(istim) = indata.acc(stimidx);
    end
    fulloacc(oaccidx+1:oaccidx+length(stims))= oacc;
    oaccidx = oaccidx+length(stims);      
    
end

mydata = [mydata fulloacc];
cols = cat(2,cols,'oacc');