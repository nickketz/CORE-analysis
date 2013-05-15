function [exper, substruct] = core_getbehavmeas(exper,cfg)
% get new behavioral measure of performance based on classifier output 
% and 'congcrit' value
%
%   input: 
%       exper = exper struct with trldata including resp column
%       cfg:
%          congcrit = percentage of congruent trials necessary to keep
%             original condition label, low values are more conservative high
%             values 'trust' classifier output more
%          eventValues = conditions labels to do selection upon
%
%   output:
%       exper = exper struct with net trldata struct
%       substruct = struct with details of new condition sorting
%

newtrldata = exper.trldata;
congcrit = cfg.congcrit;
if ~isfield(cfg,'sthres')
    cfg.sthres = 5;
end
clear substruct
substruct(length(exper.trldata))= struct('stims',[],'cond',[],'imgt',[],'cong',[],'incong',[],'newcond',[],'pctcong',[],'acc',[],'memact',[]...
    ,'smemact',[],'sumact',[],'ssumact',[]);
for isub = 1:length(exper.trldata)
    trldata = exper.trldata(isub);
    fnames = cfg.eventValues; %fieldnames(trldata);
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
            acccol = find(strcmp('acc',vars));
            maxdiffcol = find(strcmp('maxdiff',vars));
            sumdiffcol = find(strcmp('sumdiff',vars));
            repcol = find(strcmp('rep ',vars));
            %succcol = find(strcmp('succ',vars));
            
            faceinds = vals(:,imgtcol) == 1;
            sceneinds = vals(:,imgtcol) == 0;
            
            cong = union(find(vals(faceinds,respcol) == 1),find(vals(sceneinds,respcol) == 0));
            incong = union(find(vals(faceinds,respcol) == 0),find(vals(sceneinds,respcol) == 1));
            if length(cong)+length(incong) ~= size(vals,1)
                error('number of congruent and incongruent items is less than total number of items');
            end
            
            Redinds = find(vals(:,condcol) == 2);
            Blueinds = find(vals(:,condcol) == 1);
            Greeninds = find(vals(:,condcol) == 0);
            
            %get unique stims
            stims = unique(vals(:,stimcol));
            
            stimcong = nan(size(vals,1),1);
            congvec = nan(size(stims));
            incongvec = nan(size(stims));
            pctcong = nan(size(stims));
            conds = nan(size(stims));
            acc = nan(size(stims));
            memact = nan(size(stims));
            smemact = nan(size(stims));
            sumact = nan(size(stims));
            ssumact = nan(size(stims));
            imgt = nan(size(stims));
            %succ = nan(size(stims));
            
            %count the number of reps that are cong vs. incong
            for istims = 1:length(stims)
                stimind = find(vals(:,stimcol)==stims(istims));
                conds(istims) = unique(vals(stimind,condcol));
                imgt(istims) = unique(vals(stimind,imgtcol));
                %succ(istims) = vals(stimind,succcol);
                if length(unique(vals(stimind,acccol)))>1
                    error('accuracy measure inconsistent within stimulus');
                end
                acc(istims) = unique(vals(stimind,acccol));  
%                 smemact(istims) = mean(vals(intersect(repind,stimind),maxdiffcol));
%                 %smemact(istims) = mean(vals(stimind,maxdiffcol).*(vals(stimind,repcol)>cfg.sthres));
%                 memact(istims) = mean(vals(stimind,maxdiffcol));
                sumactvals = vals(stimind,sumdiffcol);
                memactvals = vals(stimind,maxdiffcol);
                repvals = vals(stimind,repcol);
%                 if unique(vals(stimind,imgtcol))==1
% %                     memact(istims) = memact(istims)*-1;%flip memact for faces, i.e. cat2-cat1
% %                     smemact(istims) = smemact(istims)*-1;
%                     memactvals = memactvals*-1;
%                     sumactvals = 1-sumactvals;
%                 end                
                sumact(istims) = mean(sumactvals);
                ssumact(istims) = mean(sumactvals(repvals>=cfg.sthres));
                memact(istims) = mean(memactvals);
                smemact(istims) = mean(memactvals(repvals>=cfg.sthres));
                cong_count = length(intersect(stimind,cong));
                congvec(istims) = cong_count;
                incong_count = length(intersect(stimind,incong));
                incongvec(istims) = incong_count;
                %calculate percentage of congruent trials
                pctcong(istims) = cong_count/(cong_count+incong_count);
                meas = memact(istims);
                % categorize this stimulus based on criteria for percentage of congruent trials               
                if meas > congcrit
                    stimcong(stimind) = 1;
                else
                    stimcong(stimind) = 0;
                end                
            end
            
            substruct(isub).stims = [substruct(isub).stims stims'];
            substruct(isub).cond = [substruct(isub).cond conds'];
            substruct(isub).imgt = [substruct(isub).imgt imgt'];
            %substruct(isub).succ = [substruct(isub).succ succ'];
            substruct(isub).cong = [substruct(isub).cong congvec'];
            substruct(isub).incong = [substruct(isub).incong incongvec'];
            substruct(isub).pctcong = [substruct(isub).pctcong pctcong'];
            substruct(isub).acc = [substruct(isub).acc acc'];
            substruct(isub).memact = [substruct(isub).memact memact'];
            substruct(isub).smemact = [substruct(isub).smemact smemact'];
            substruct(isub).sumact = [substruct(isub).sumact sumact'];
            substruct(isub).ssumact = [substruct(isub).ssumact ssumact'];
            
            newcond = nan(size(vals,1),1);
            
            newcond(intersect(Blueinds,find(stimcong==1))) = 1;
            newcond(intersect(Blueinds,find(stimcong==0))) = 2;
            
            newcond(intersect(Redinds,find(stimcong==0))) = 2;
            newcond(intersect(Redinds,find(stimcong==1))) = 1;
            
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

