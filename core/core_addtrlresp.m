function [exper,trldata] = core_addtrlresp(test_result,conds,ntrials,subStr,exper)
% function to add the classifier category prediction to the trldata matrix
% for a give subject
%
%   input:
%       test_restul = structure returned from nk_ft_evaluateprobe
%       cond = conditions the classifier was tested on
%       ntrials = cell array matching test_cond dims with # of trials in
%       each condition
%       subStr = string of subject in which nk_ft_evaluateprobe was run
%       adFile = analysis details file
%
%   output:
%       exper = new exper struct to replace input old version
%

%[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);

%find subject index in case we've only loaded a subset of the full subject
%list
if length(exper.subjects)~=length(exper.trldata)
    error('ambiguous subject indicies');
else
    subind = find(strcmp(subStr,exper.subjects));
end

% copy out that subjects trldata from exper
trldata = exper.trldata(subind);      
trlind = 0;
%itype = 2;%test conditions
for ilabel = 1:length(conds)
    for iconds = 1:length(conds{ilabel})
        %if the 'resp' column already exists replace those values otherwise
        %add a new column
        trlind = trlind(end)+1:trlind(end)+ntrials{ilabel}(iconds);
        
        resp = test_result.resp(trlind);
        respind = strcmp('resp',trldata.(conds{ilabel}{iconds}).vars);
        if sum(respind)==0
            trldata.(conds{ilabel}{iconds}).vars{end+1} = 'resp';
            trldata.(conds{ilabel}{iconds}).vals(:,end+1) = resp-1;
        elseif sum(respind)==1
            fprintf('Overwritting existing resp column!!\n');
            trldata.(conds{ilabel}{iconds}).vals(:,respind) = resp-1;
        else
            error('multiple resp columns found in trldata');
        end
        
        if isfield(test_result,'maxdiff') %add maxdif to trldata if it exists in testresult
            maxdif = test_result.maxdiff(trlind);
            
            difind = strcmp('maxdiff',trldata.(conds{ilabel}{iconds}).vars);
            if sum(difind)==0
                trldata.(conds{ilabel}{iconds}).vars{end+1} = 'maxdiff';
                trldata.(conds{ilabel}{iconds}).vals(:,end+1) = maxdif;
            elseif sum(difind)==1
                fprintf('Overwritting existing maxdiff column!!\n');
                trldata.(conds{ilabel}{iconds}).vals(:,difind) = maxdif;
            else
                error('multiple maxdiff columns found in trldata');
            end
        end
        
        if isfield(test_result,'sumdiff') %add sumdiff to trldata if it exists in testresult
            sumdiff = test_result.sumdiff(trlind);
            
            difind = strcmp('sumdiff',trldata.(conds{ilabel}{iconds}).vars);
            if sum(difind)==0
                trldata.(conds{ilabel}{iconds}).vars{end+1} = 'sumdiff';
                trldata.(conds{ilabel}{iconds}).vals(:,end+1) = sumdiff;
            elseif sum(difind)==1
                fprintf('Overwritting existing sumdiff column!!\n');
                trldata.(conds{ilabel}{iconds}).vals(:,difind) = sumdiff;
            else
                error('multiple sumdiff columns found in trldata');
            end
        end
        
    end
end
exper.trldata(subind) = trldata;