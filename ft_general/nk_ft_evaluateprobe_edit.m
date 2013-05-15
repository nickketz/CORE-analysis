function outdata = nk_ft_evaluateprobe_edit(test_stat,design,method,doplot)
% evaluates test results from probed model
%
%   input:
%       test_stat = struc returned from nk_ft_probemodel, must contain
%       'result' field
%       design =  design matrix with ground truth for test data, first
%       row is imgt 1=scene 2=faces, second row is condition type
%       0=green 1=blue 2=red
%       method = str of way to calculate classifier resp (maxdiff, sumdiff)
%
%   output:
%       outdata = struc containing fields:
%           resp = response estimated from max difference between conds
%           accuracy = accuracy of resp against design
%           p = bootstrapped p value against from permutation test
%

if ~exist('doplot','var')
    doplot = 0;
end


mydesign = design;
design = mydesign(1,:);
designcond = mydesign(2,:);

mydif = zeros(size(test_stat(1).result,1),length(test_stat));
for i = 1:length(test_stat)
    mystat = test_stat(i).result;
    for j = 1:size(mystat,1)
        mydif(j,i) = mystat(j,1) - mystat(j,2);
    end
end


% max difference
[val, ival] = max(abs(mydif),[],2);
maxdif = nan(1,length(ival));
cresp = nan(length(ival),2);
for i = 1:length(ival)
    temp = test_stat(ival(i)).result(i,:);
    maxdif(i) = temp(1)-temp(2);
end

% summed difference
sumdif = mean(mydif>0,2);

resp = nan(1,size(mydif,2));
switch method
    case 'maxdiff'
        for i = 1:length(ival)
            temp = test_stat(ival(i)).result(i,:);
            maxdif(i) = temp(1)-temp(2);
            cresp(i,:) = temp;
            if temp(1) > temp(2)
                resp(i) = 1;
            else
                resp(i) = 2;
            end
        end
        
    case 'sumdiff'
        for i= 1:length(sumdif)
            if sumdif(i) > 0.5
                resp(i) = 1;
            else
                resp(i) =2;
            end
        end
        cresp = sumdif;
        
    otherwise
        error('unrecognized testing method');
end

try
    %% calc auc
    auc = nan(length(unique(designcond)),1);
    conds = sort(unique(designcond));
    
    for icond = 1:length(conds)
        labels = design(designcond==conds(icond));
        myresp = cresp(designcond==conds(icond),1);
        [xroc,yroc,troc,myauc] = perfcurve(labels',myresp,1);
        auc(icond) = myauc;
    end
    
    %% outdata
    
    outdata.resp = resp;
    outdata.design = design;
    outdata.auc = auc;
    outdata.sumdiff = sumdif;
    outdata.maxdiff = maxdif;
    outdata.method = method;
    
catch
    outdata.error = 1;
    fprintf('Error in evaluating probe\n');
    return
end
outdata.error = 0;

