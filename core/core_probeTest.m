function [testresp,trainednet] = core_probeTest(cfg,adFile)

%add testresp struct to ana
%add resp vector to end of trldata in exper
% modified version to validate performance based on testing in a different
% condition, i.e. train network on given latency, then test across
% latencies.  Done in a single subject so that it can be run distributed
% across nodes
%
%
%   input:
%       cfg:
%           sub = subject to run train/test on
%           doplots = 1/0 do plots
%           savedata = save test results to file DOES NOT SAVE AD FILE!
%           cname = classifier name used in crossvalidated training
%           dobaseline = 0/1 do baseline correction from -.3 to -.1
%           frequency = frequency range to train/test over(should be the
%             same as crossvalidated data)
%           trainlatency = two value vector to do training on, distance
%             between values specified latecy width for testing
%           testlatency = two value vector of start and end latency to test
%           testconds = cell array of conditions to get resp values for,
%             WARNING requires particular formatting to create design matrix
%             correctly
%       adFile = file with analysis details to load
%
%   output:
%       newtrldata = trldata struct with resp vector added
%       testresp = struct with details of testing (saved to file if
%         cfg.savedata is true);
%
%

%load analysis details
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);
files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 150;

cfg_train = [];
cfg_train.cname = cfg.cname;
cfg_train.frequency = cfg.frequency;
cfg_train.conds = cfg.trainconds;

cfg_train.sub = cfg.sub;

%cfg_test.latwidth = cfg.trainlatency(2) - cfg.trainlatency(1);

%% load specific subject data
subStr = cfg_train.sub;%{'CORE 02'};
evts = cat(2,cfg.testconds{1}{:},cfg.testconds{2}{:});
[ssexper,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile, subStr,evts);
if cfg.dobaseline == 1;
    cfg_fb = [];
    cfg_fb.baseline = [-.3 -.1];
    cfg_fb.baselinetype = 'absolute';
    data_freq = nk_ft_baselinecorrect(data_freq,ana,ssexper,cfg_fb);
end

%% train classifierand probe on new data

% cell struct for design matrix creation:
% main two cells : {trainconds}, {testconds}
% within test or train cells each cell specifies a condition label for
% the classifier
% within each condition label cell each cell is a TF condition which is
% concatenated into a single label
% must have same number of condition labels in train and test cells

conds = cfg.testconds;

%train/test - labels -
ntrials = {};
design = {};
data = {};
subNo = find(strcmp(ssexper.subjects,cfg_train.sub));
%make design matrix
for itype = 1:length(conds)
    design{itype} = [];
    for ilabel = 1:length(conds{itype})
        for iconds = 1:length(conds{itype}{ilabel})
            ntrials{itype}{ilabel}(iconds) = size(data_freq.(conds{itype}{ilabel}{iconds}).sub(subNo).ses.data.powspctrm,1);            
            design{itype} = [design{itype} ilabel*ones(1,ntrials{itype}{ilabel}(iconds))];
            data{itype}{ilabel}{iconds} = data_freq.(conds{itype}{ilabel}{iconds}).sub(subNo).ses.data;
        end
    end
end
    
%get train dat matrix
cfg_train.frequency = cfg.frequency;
cfg_train.latency = cfg.trainlatency;
cfg_train.design = design{1};
cfg_train.conds = conds{1};
cfg_train.resample = true; %upsample deficient conditions to match trial numbers

%get test dat matrix
cfg_test = [];
cfg_test.frequency = cfg.frequency;
cfg_test.latency = cfg.testlatency;%[.5 2];
cfg_test.conds = conds{2};
cfg_test.design = design{2};

%set probemodel cfg
cfg_pm = [];
cfg_pm.train = cfg_train;
cfg_pm.test = cfg_test;

cfg_pm.testlatencies = cfg_pm.test.latency(1):cfg.testlatwidth:cfg_pm.test.latency(2);
cfg_pm.mva = cfg.mva;
cfg_pm.subNo = subNo;

%train classifier on full training data, and then get test output
[test_stat,traindata] = nk_ft_probemodel(cfg_pm, data_freq);

if isfield(cfg,'valconds')
    newdesign = design{2};
    ind = 1;
    mytrials = cat(2,ntrials{2}{:});
    valconds = cat(2,cfg.valconds{:});
    if size(mytrials)~=size(valconds)
        error('valconds must have a value for each testing condition');
    end
    for ivalconds = 1:length(mytrials)
        newdesign(ind:ind+mytrials(ivalconds)-1) = valconds(ivalconds).*newdesign(ind:ind+mytrials(ivalconds)-1);
        ind = ind+mytrials(ivalconds);
    end
else
    newdesign = design{2};
end
test_result = nk_ft_evaluateprobe(test_stat,newdesign,0);

%make testresp struct, includes traindata and resp vector
trainednet = traindata.trainednet;
traindata = rmfield(traindata,'trainednet');
tempstruct.traindata = traindata;
tempstruct.testdata = test_stat;
tempstruct.testresult = test_result;
tempstruct.conds = conds;
cfg_pm.ntrials = ntrials;
cfg_pm.valconds = cfg.valconds;
tempstruct.cfg = cfg_pm;

if cfg.savedata ==1;
    %save testresp as it is too large for AD file
    tempstr = {};
    for iconds = 1:length(cfg_train.conds)
        tempstr{iconds} = sprintf('%s+',cfg_train.conds{iconds}{:});
        tempstr{iconds} = tempstr{iconds}(1:end-1);
    end
    vsstr = sprintf('%sVs%s',tempstr{:});
    %set defaults
    cfg_train.avgoverfreq = ft_getopt(cfg_train, 'avgoverfreq', 'no');
    cfg_train.avgovertime = ft_getopt(cfg_train, 'avgovertime', 'no');
    savedir = fullfile(dirs.saveDirProc, cfg_train.sub, 'pow_testresp');
    if ~exist(savedir,'dir')
        mkdir(savedir);
    end
    savefile =  sprintf('pow_testresp_%s_%.3f_%.3f_%.3f_%.3f', cfg_train.cname, cfg_train.frequency, cfg_pm.train.latency);
    if strcmp(cfg_train.avgoverfreq,'yes')
        savefile = [savedir '_avgt'];
    end
    if strcmp(cfg_train.avgovertime,'yes');
        savefile = [savefile '_avgf'];
    end
    savefile = [savedir filesep savefile '.mat'];
    fprintf('Saving testresp struct to:\n %s\n',savefile);
    testresp = tempstruct;
    if exist(savefile,'file')
        fprintf('WARNING file already exists, overwritting\n');
    end
    save(savefile,'testresp','trainednet');
    fprintf('Done\n');
end

     
