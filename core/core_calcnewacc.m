function [newtrldata,acc,oldacc,n] = core_calcnewacc(newtrldata,conds,dirs,exper,doplots)
% calc new behav accuracy based on new conditio labels
% 
%   input:
%       newtrldata= likely the output of core_getbheavmeas, trldata struct
%       with classifier resp column included, and a succ column indicating
%       successfull or insuccessful retrieval of studied images(set in
%       core_getbehavmeas)
%       conds = conditions to use in acc calculation (usually
%       ana.eventValues)
%       dirs = dirs struct
%       exper = exper struct 
%
%   ouptput:
%       newtrldata = input trldata with a newcondition label column
%       included, this label is based on the percentage of trials that were
%       congruent or incongruent with the studied image category.  The
%       percentage is set by 


if ~exist('doplots','var')
    doplots = 1;
end

acc.all = nan(length(newtrldata),3);
acc.faces = acc.all;
acc.scenes = acc.all;
n = acc;
oldacc.all = nan(length(newtrldata),4);
oldacc.faces = oldacc.all;
oldacc.scenes = oldacc.all;
nbaseline = [];
for isub = 1:length(newtrldata)
    trldata = newtrldata(isub);
    fnames = conds;
    accvec = [];
    newcondvec = [];
    imgtvec = [];
    
    %load behav data
    behavdir = fullfile(dirs.dataroot,dirs.dataDir,'ses1','behav');
    bfile = [behavdir filesep 'CORE_acc2_subj' exper.subjects{isub}(end-1:end) '.mat'];
    load(bfile,'stimmat','acc_cor');
    %calc oldacc
    for itype = 1:4
        sceneidx = stimmat(:,3) == 0;
        faceidx = stimmat(:,3) == 1;
        idx = stimmat(:,end)==itype-1;
        oldacc.all(isub,itype) = mean(acc_cor(idx));
        oldacc.scenes(isub,itype) = mean(acc_cor(idx&sceneidx));
        oldacc.faces(isub,itype) = mean(acc_cor(idx&faceidx));
        if itype ==4
            nbaseline.all(isub) = sum(idx);
            nbaseline.faces(isub) = sum(idx&faceidx);
            nbaseline.scenes(isub) = sum(idx&sceneidx);
        end        
    end        
    
    for icond = 1:length(fnames)
        vars = trldata.(fnames{icond}).vars;
        if sum(strcmp('newcond',vars))==0
            fprintf('subject %s has no newcond column in their trldata for condition %s,skipping\n',exper.subjects{isub},fnames{icond});
            continue
        else
            vals = trldata.(fnames{icond}).vals;
            %create new condition label based on classifier output
            newcondcol = find(strcmp('newcond',vars));
            acccol = find(strcmp('acc',vars));
            stimcol = find(strcmp('stim',vars));
            imgtcol = find(strcmp('imgt',vars));
            
            [jnk,stimui] = unique(vals(:,stimcol));
            accvec = [accvec vals(stimui,acccol)'];
            newcondvec = [newcondvec vals(stimui,newcondcol)'];
            imgtvec = [imgtvec vals(stimui,imgtcol)'];
        end
    end
    for itype = 1:3
        acc.all(isub,itype) = mean(accvec(newcondvec==itype-1));
        acc.scenes(isub,itype) = mean(accvec( (newcondvec==itype-1) & (imgtvec == 0) ));
        acc.faces(isub,itype) = mean(accvec( (newcondvec==itype-1) & (imgtvec == 1) ));
        n.all(isub,itype)= sum(newcondvec==itype-1);
        n.faces(isub,itype) = sum((newcondvec==itype-1) & (imgtvec == 1));
        n.scenes(isub,itype) = sum((newcondvec==itype-1) & (imgtvec == 0));
    end
end
acc.all = [acc.all oldacc.all(:,end)];
acc.scenes = [acc.scenes oldacc.scenes(:,end)];
acc.faces = [acc.faces oldacc.faces(:,end)];
n.all = [n.all nbaseline.all'];
n.faces = [n.faces nbaseline.faces'];
n.scenes = [n.scenes nbaseline.scenes'];
if doplots
    myacc = acc;
    CORE_nanplotacc(myacc);
    %ylim([.5 1]);
    title('new acc');
    myoldacc = oldacc;
    CORE_plotacc(myoldacc);
    title('old acc');
    %ylim([.5 1]);
end