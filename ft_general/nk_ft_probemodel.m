function [s,traindata] = nk_ft_probemodel(cfg, data_freq)

% first trains model on data_train and then tests using that model on
% various time intervals of data_test
% 
%   input:
%       cfg.traindesign = design matrix for training data
%       cfg.testdesign = design matrix for testing data
%       cfg.trainlatency = starting time for training data
%       cfg.testlatency = array of starting points for testing data
%       cfg.latencywidth = how wide a temporal window the model sees
%       cfg.frequency = frequency range for models to run on
%       cfg.mva = dml identifier of methods to use
%       cfg.statistic = statisics to perform on train and test perf
%
%       data_freq = freq_analysis data structure 
%
%   output:
%       perf = structure with test output values across time intervals as
%       wella as various statistics acquired in the testing
%
 

if ~isfield(cfg,'mva')
    cfg.mva = dml.analysis({ ...
        dml.standardizer('verbose',true) ...
        dml.svm('verbose',true) ...
        });
    fprintf('using default svm with zscore...\n');
else
    if ~isa(cfg.mva,'dml.analysis')
        cfg.mva = dml.analysis(cfg.mva);
    end
end

if ~isfield(cfg,'statistic'),
    cfg.statistic = {'accuracy' 'binomial'};
end

if isfield(cfg,'trainednet')
    traindata = cfg.trainednet;
    fprintf('using supplied pre-trained network...\n');
    trainednet = traindata.trainednet.method{end};
else
    %get training data
    tempdata = {};
    for ilabel = 1:length(cfg.train.conds)
        for icond = 1:length(cfg.train.conds{ilabel})
            tempdata = cat(2,tempdata,data_freq.(cfg.train.conds{ilabel}{icond}).sub(cfg.subNo).ses.data);
        end
    end
    
    [dat,traindata] = nk_ft_datprep(cfg.train,tempdata{:});
    if any(isinf(dat(:)))
        warning('Inf encountered; replacing by zeros');
        dat(isinf(dat(:))) = 0;
    end
    
    if any(isnan(dat(:)))
        warning('Nan encountered; replacing by zeros');
        dat(isnan(dat(:))) = 0;
    end
    
    cv = cfg.mva;
    
    % perform training
    labelstr = '';
    for ilabel = 1:length(cfg.train.conds)        
        condstr = sprintf('%s,',cfg.train.conds{ilabel}{:});
        labelstr = sprintf('%s\n  %d(%s)',labelstr,ilabel,condstr(1:end-1));
    end
    fprintf('Performing classifier training on labels%s\nin time window %f to %fs\nwith frequencies %d to %d...\n',...
        labelstr, cfg.train.latency, cfg.train.frequency);
    tic;
    cv = cv.train(dat',traindata.cfg.design');
    trainresult = cv.test(dat');
    fprintf('Done in %f seconds\n',toc);    
    trainednet = cv.method{end};
    traindata.trainednet = cv;
    traindata.result = trainresult;
    
end
traindatsize = size(trainednet.weights)-1;%minus one for the bias weight



%MUST Z SCORE EACH DATA SET SEPARATELY!!!

%iterate over testing intervals
%get testing data
tempdata = {};
for ilabel = 1:length(cfg.test.conds)
    for icond = 1:length(cfg.test.conds{ilabel})
        tempdata = cat(2,tempdata,data_freq.(cfg.test.conds{ilabel}{icond}).sub(cfg.subNo).ses.data);
    end
end

latwidth = cfg.train.latency(2) - cfg.train.latency(1);

tic;
[delta, ind] = min(abs(cfg.testlatencies-(cfg.testlatencies(end)-latwidth)));
s = struct();%cell(1,length(cfg.testlatencies(1:ind)));
for itest = 1:length(cfg.testlatencies(1:ind))
    cfg.test.latency = [cfg.testlatencies(itest) cfg.testlatencies(itest)+latwidth];
    
    %get testdata
    [dat,testdata] = nk_ft_datprep(cfg.test,tempdata{:});
    while size(dat,1) ~= traindatsize(1)
        fprintf('feature size mismatch, test: %d, train: %d\n',size(dat,1),traindatsize(1));
        if size(dat,1) > traindatsize(1)
            cfg.test.latency(2) = cfg.test.latency(2) - .01;             
        else
            cfg.test.latency(2) = cfg.test.latency(2) + .01;
        end        
        fprintf('test latency adjusted to %fto%f\n',cfg.test.latency);       
        [dat,testdata] = nk_ft_datprep(cfg.test,tempdata{:});
    end

    if any(isinf(dat(:)))
        warning('Inf encountered; replacing by zeros');
        dat(isinf(dat(:))) = 0;
    end
    
    if any(isnan(dat(:)))
        warning('Nan encountered; replacing by zeros');
        dat(isnan(dat(:))) = 0;
    end

    %perform testing on trained model
    labelstr = '';
    for ilabel = 1:length(cfg.test.conds)        
        condstr = sprintf('%s, ',cfg.test.conds{ilabel}{:});
        labelstr = sprintf('%s\n  %d(%s)',labelstr,ilabel,condstr(1:end-2));
    end
    fprintf('Performing testing using trained model on labels%s\nin time window %f to %fs\nwith frequencies %d to %d...\n',...
        labelstr, cfg.test.latency, cfg.test.frequency);
    
    tstart = tic;
    m = dml.standardizer;
    m = m.train(dat');
    z = m.test(dat');
    testdata.result = trainednet.test(z);
    testdata.subNo = cfg.subNo;
    if itest ==1;
        s = testdata;
    else
        s(itest) = testdata;
    end
    tstop = toc;
    fprintf('Done in %f seconds\n',tstop);
end
fprintf('\nTotal testing time %f seconds\n',toc);



