function [exper, substruct] = core_getbehavmeas(exper,congcrit)
% get new behavioral measure of performance based on classifier output 
% and 'congcrit' value
%
%   input: 
%       exper = exper struct with trldata including resp column
%       congcrit = percentage of congruent trials necessary to keep
%         original condition label, low values are more conservative high
%         values 'trust' classifier output more
%
%   output:
%       exper = exper struct with net trldata struct
%       substruct = struct with details of new condition sorting
%

newtrldata = exper.trldata;
clear substruct
substruct(length(exper.trldata))= struct('stims',[],'cong',[],'incong',[],'cond',[],'newcond',[]);
for isub = 1:length(exper.trldata)
    trldata = exper.trldata(isub);
    fnames = fieldnames(trldata);
    substims = [];
    subcong= [];
    subincong=[];
    for icond = 1:length(fnames)
        vars = trldata.(fnames{icond}).vars;
        if sum(strcmp('resp',vars))==0
            fprintf('subject %s has no resp column in their trldata for condition %s,skipping\n',exper.subjects{isub},fnames{icond});
            continue
        else
            vals = trldata.(fnames{icond}).vals; 
            
            %create new condition label based on classifier output
            condcol = find(strcmp('cond',vars));
            imgtcol = find(strcmp('imgt',vars));
            respcol = find(strcmp('resp',vars));
            stimcol = find(strcmp('stim',vars));
            
            faceinds = vals(:,imgtcol) == 1;
            sceneinds = vals(:,imgtcol) == 0;
            
            cong = union(find(vals(faceinds,respcol) == 1),find(vals(sceneinds,respcol) == 0));
            incong = union(find(vals(faceinds,respcol) == 0),find(vals(sceneinds,respcol) == 1));
            
            Redinds = find(vals(:,condcol) == 2);
            Blueinds = find(vals(:,condcol) == 1);
            Greeninds = find(vals(:,condcol) == 0);
            
            %get unique stims
            stims = unique(vals(:,stimcol));
            
            stimcong = nan(size(vals,1),1);
            congvec = nan(size(stims));
            incongvec = nan(size(stims));
            conds = [];
            
            %count the number of reps that are cong vs. incong
            for istims = 1:length(stims)
                stimind = find(vals(:,stimcol)==stims(istims));
                conds(istims) = unique(vals(stimind,condcol));
                cong_count = length(intersect(stimind,cong));
                congvec(istims) = cong_count;
                incong_count = length(intersect(stimind,incong));
                incongvec(istims) = incong_count;
                %calculate percentage of congruent trials
                meas = cong_count/(cong_count+incong_count);
                % categorize this stimulus based on criteria for percentage of congruent trials               
                if meas > congcrit
                    stimcong(stimind) = 1;
                else
                    stimcong(stimind) = 0;
                end                
            end
            
            substruct(isub).stims = [substruct(isub).stims stims'];
            substruct(isub).cong = [substruct(isub).cong congvec'];
            substruct(isub).incong = [substruct(isub).incong incongvec'];
            substruct(isub).cond = [substruct(isub).cond conds];
            
            newcond = nan(size(vals,1),1);
            
            newcond(intersect(Blueinds,find(stimcong==1))) = 1;
            newcond(intersect(Blueinds,find(stimcong==0))) = -1;
            
            newcond(intersect(Redinds,find(stimcong==0))) = 2;
            newcond(intersect(Redinds,find(stimcong==1))) = -1;
            
            newcond(intersect(Greeninds,find(stimcong==1))) = 0;
            newcond(intersect(Greeninds,find(stimcong==0))) = 0;
            
            for istims = 1:length(stims)
                stimind = find(vals(:,stimcol)==stims(istims));
                substruct(isub).newcond = [substruct(isub).newcond mean(newcond(stimind))'];
            end
            
            %add column to trldata
            newcondcol = strcmp('newcond',vars);
            if sum(newcondcol)==0
                trldata.(fnames{icond}).vars{end+1} = 'newcond';
                trldata.(fnames{icond}).vals(:,end+1) = newcond;
            else
                trldata.(fnames{icond}).vals(:,newcondcol) = newcond;
            end
 
        end
    end
    newtrldata(isub) = trldata;
end
exper.trldata = newtrldata;
exper.congcrit = congcrit;

