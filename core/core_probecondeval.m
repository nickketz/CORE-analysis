function outdata = core_probecondeval(data,doplot)

% do bootstrapped accuracy measure on three core conditions and return acc
% and p vectors 
%
%   input:
%       data = result from nk_ft_evaluateprobe
%       doplot = bool on plots
%
%   output
%       outdata =
%           acc = accuracy 
%           p = bootstrapped probability of false positive
%           conds = condition labels


if isempty(doplot)
    doplot=0;
end

testmat = eye(length(data.ntrials{2}{1}),length(data.ntrials{2}{1}));
acc = nan(1,size(testmat,1));
p = nan(size(acc));
conds = data.conds{2};
ntrials = data.ntrials{2};

for itest = 1:3
    testind = testmat(itest,:);    
    resp = [];
    respind = 0;
    for itype = 1:length(ntrials)
        for icond = 1:length(conds{itype})
            resp = [resp data.resp(respind+1:respind+ntrials{itype}(icond)).*testind(icond)];
            respind = respind + ntrials{itype}(icond);
        end
    end
    trialind = resp~=0;
    resp = resp(trialind);
    design = data.design(1,trialind);
    
    temp = calc_boot(resp,design,0);
    
    acc(itest) = temp.acc;
    p(itest) = temp.p;
    
end

outdata.acc = acc';
outdata.p = p';
outdata.conds = conds;








