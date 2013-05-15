function [stat] = nk_ft_pow_train(cfg,varargin)

% CORE specfic function to search subject powspctrm for optimal time period
% in which to run classification on faces and scenes.  Designed to run on
% multiple cores simultaneously by specifying cfg.infile and cfg.outfile
%
%   input:
%       cfg.infile      = adFile to specify ft strcut
%       cfg.outfile     = file to save results to
%       cfg.subStr      = subject to run process on
%       cfg.latency     = time period to run classifier on('all')
%       cfg.baselinecorrect = do baseline correction(0)
%       cfg.avgoverfreq     = average over specified frequency range('no')
%       cfg.avgovertime     = average over latency range('no')
% 
%   output:
%       stat    = data structure resulting from crossvalidated
%       classification, if cfg.outfile is specified this stat struct is
%       saved out
%

%set defaults
cfg.avgoverfreq = ft_getopt(cfg, 'avgoverfreq', 'no');
cfg.avgovertime = ft_getopt(cfg, 'avgovertime', 'no');


if isfield(cfg,'infile') %if infile specified load analysis details
    adFile = cfg.infile;    
    % load in the subject data
    eventValues = cat(2,cfg.conds{1},cfg.conds{2});
    [exper,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile,cfg.subStr,eventValues);
%    [data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow');
    
    if isfield(cfg,'baselinecorrect')
        if cfg.baselinecorrect
            % Change in freq relative to baseline using absolute power
            cfg_fb = [];
            cfg_fb.baseline = [-0.3 -0.1];
            cfg_fb.baselinetype = 'absolute';
            data_freq = nk_ft_baselinecorrect(data-freq,ana,exper,cfg_fb);
        end
    end
    
else %outherwise data_freq must be included
    if isempty(varargin)
        error('Must specify an infile otherwise data_freq, dirs, and exper must be included (in that order) as input parameter');
    else
        data_freq = varargin{1};
        dirs = varargin{2};
        exper = varargin{3};
    end    
end


%% train classifier on specified conditions
%must have dml toolbox added to path, path of the external toolboxes
%included with fieldtrip
design = [];
%data = cell(1,length(cfg.conds));
subNo = find(strcmp(cfg.subStr,exper.subjects));%cfg.subNo;
linind = 0;
ntrials = zeros(length(cfg.conds),length(cfg.conds{1}));
for iconds = 1:length(cfg.conds)
    for icat = 1:length(cfg.conds{iconds})
        linind = linind +1;
        data{linind} = data_freq.(cfg.conds{iconds}{icat}).sub(subNo).ses.data;
        %make design matrix while we're at it
        design = [design; iconds*ones(size(data{linind}.powspctrm,1),1)];
        ntrials(iconds,icat) = size(data{linind}.powspctrm,1);
    end
end

%look for non-default design matrix
if ~isfield(cfg,'design')
    cfg.design = design';
end

%create testfolds?
if isfield(cfg,'testconds')
    if sum(sum(cfg.testconds)) > 0
        cfg.method = 'crossvalidate_nk';
        fprintf('creating sample indices using %d-fold cross-validation\n',cfg.nfolds);
        y = cell(cfg.nfolds,1);
        Y = design;
        % determine indices of labeled (non-nan) datapoints
        % nan datapoints should end up in the training set
        labeled = [];
        for icond = 1:length(cfg.conds)
            for icat = 1:length(cfg.conds{1})
                labeled = [labeled cfg.testconds(icond,icat).*ones(1,ntrials(icond,icat))];
            end
        end
        labeled = find(labeled' ~= 0);
        
        % randomize labeled trials
        nsamples = size(labeled,1);
        idxs = labeled(randperm(nsamples));
        
        % make sure outcomes are evenly represented whenever possible
        [t,t,idx] = unique(Y,'rows');
        mx = max(idx);
        if mx == nsamples % unique samples            
            for f=1:cfg.nfolds
                y{f} = idxs((floor((f-1)*(length(idxs)/obj.folds))+1):floor(f*(length(idxs)/obj.folds)));
            end            
        else            
            % take labeled indices
            idx = idx(idxs);            
            f=1;
            for j=1:mx
                iidx = find(idx == j);
                for k=1:length(iidx)
                    y{f} = [y{f}; idxs(iidx(k))];
                    f = f+1; if f > cfg.nfolds, f=1; end
                end
            end            
        end
        cfg.testfolds = y;
    else
        fprintf('no conditions specified in testconds for testfolds, using default fold generation\n');        
    end
end
    

% specifiy classifier details
% cfg_cd.latency = cfg.latency;
% cfg_cd.frequency = cfg.frequency;
% cfg_cd.design = design';
% cfg_cd.mva     = cfg.mva;
% cfg_cd.nfolds  = cfg.nfolds;

if ~isfield(cfg,'method')
    cfg.method = 'crossvalidate';
end

% run classifier 
stat           = ft_freqstatistics(cfg,data{:});
statistic = stat.statistic;
%save data?
if isfield(cfg,'savedata')
    if cfg.savedata
        
        %create outfile str
        if strcmp(cfg.avgoverfreq,'yes')
            outdir = fullfile(dirs.saveDirProc, exper.subjects{subNo}, sprintf('pow_classify_%s_%d_%d_avg',cfg.name,cfg_cd.frequency));
        else
            outdir = fullfile(dirs.saveDirProc, exper.subjects{subNo}, sprintf('pow_classify_%s_%d_%d',cfg.name,cfg.frequency));
        end

        if ~exist(outdir,'dir')
            mkdir(outdir);
        end
        
        tempstr = {};
        for iconds = 1:length(cfg.conds)
            tempstr{iconds} = sprintf('%s+',cfg.conds{iconds}{:});
            tempstr{iconds} = tempstr{iconds}(1:end-1);
        end
        vsstr = sprintf('%sVs%s',tempstr{:});
        
        lats = int32(cfg.latency*1000);
        if strcmp(cfg.avgovertime,'yes')
            outfile = fullfile(outdir,sprintf('pow_classify_%s_%s_%d_%d_%d_%d_avg.mat',cfg.name, vsstr,cfg.frequency,lats));
        else
            outfile = fullfile(outdir,sprintf('pow_classify_%s_%s_%d_%d_%d_%d.mat',cfg.name, vsstr,cfg.frequency,lats));
        end
            
        if exist(outfile,'file')
            warning('Data file already exists!! Overwriting!');
        end
        fprintf('Saving file %s...\n',outfile);
        save(outfile,'stat','statistic','cfg');
        fprintf('Done.\n');        
    end
end
