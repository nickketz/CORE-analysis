function perf = core_ft_probemodel(cfg, data_train, data_test)

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
%       data_test = testing data
%       data_train = training data
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
else
  if ~isa(cfg.mva,'dml.analysis')
    cfg.mva = dml.analysis(cfg.mva);
  end
end

if ~isfield(cfg,'statistic'),
  cfg.statistic = {'accuracy' 'binomial'};
end

cv = dml.crossvalidator('mva',cfg.mva,'type','nfold','folds',cfg.nfolds,'compact',true,'verbose',true,'trainfolds',trainfold);

if any(isinf(dat(:)))
  warning('Inf encountered; replacing by zeros');
  dat(isinf(dat(:))) = 0;
end

if any(isnan(dat(:)))
  warning('Nan encountered; replacing by zeros');
  dat(isnan(dat(:))) = 0;
end

% perform everything!
cv = cv.train(dat',design');

% the statistic of interest
s = cv.statistic(cfg.statistic);
for i=1:length(cfg.statistic)
 stat.statistic.(cfg.statistic{i}) = s{i};
end

% get the model averaged over folds
stat.model = cv.model; 
stat.obj = cv;

fn = fieldnames(stat.model{1});
for i=1:length(stat.model)
  
  for k=1:length(fn)
    if numel(stat.model{i}.(fn{k}))==prod(cfg.dim)
      stat.model{i}.(fn{k}) = squeeze(reshape(stat.model{i}.(fn{k}),cfg.dim));
    end
  end
     
end
  
% required
stat.trial = [];
