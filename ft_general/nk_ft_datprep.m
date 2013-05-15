function [dat,stat] = nk_ft_datprep(cfg, varargin)

% NK_FT_DATPREP is function that checks and resizes a ft data structure to
% prep it for the various statistics functions.  The output is that dat
% structure usually passed to the ft_statistics_* functions.  This is
% created so that both a training and test data set can be used with the dml toolbox
%
% Use as
%   [dat] = ft_freqstatistics(cfg, freq1, freq2, ...)
% where the input data is the result from FT_FREQANALYSIS, FT_FREQDESCRIPTIVES
% or from FT_FREQGRANDAVERAGE.
%
% The configuration can contain the following options for data selection
%   cfg.channel     = Nx1 cell-array with selection of channels (default = 'all'),
%                     see FT_CHANNELSELECTION for details
%   cfg.latency     = [begin end] in seconds or 'all' (default = 'all')
%   cfg.trials      = trials to be included or 'all'  (default = 'all')
%   cfg.frequency   = [begin end], can be 'all'       (default = 'all')
%   cfg.avgoverchan = 'yes' or 'no'                   (default = 'no')
%   cfg.avgovertime = 'yes' or 'no'                   (default = 'no')
%   cfg.avgoverfreq = 'yes' or 'no'                   (default = 'no')
%   cfg.parameter   = string                          (default = 'powspctrm')
%
% Must also contain a design matrix that will eventually be used in the
% statistics function of the output dat structure this function returns. 
%   cfg.design      = design vector specifying the various conditions that
%                     each of the trails fall into.  
%
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following options:
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%


%revision = '$Id: ft_freqstatistics.m 6213 2012-07-03 19:53:05Z roboos $';

% do the general setup of the function
ft_defaults
ft_preamble help
ft_preamble callinfo
ft_preamble trackconfig
ft_preamble loadvar varargin

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'required',    {'design'});

% set the defaults
cfg.outputfile  = ft_getopt(cfg, 'outputfile',  []);
cfg.parameter   = ft_getopt(cfg, 'parameter',   []); % the default is assigned further down
cfg.channel     = ft_getopt(cfg, 'channel',     'all');
cfg.latency     = ft_getopt(cfg, 'latency',     'all');
cfg.trials      = ft_getopt(cfg, 'trials',      'all');
cfg.frequency   = ft_getopt(cfg, 'frequency',   'all');
cfg.avgoverchan = ft_getopt(cfg, 'avgoverchan', 'no');
cfg.avgoverfreq = ft_getopt(cfg, 'avgoverfreq', 'no');
cfg.avgovertime = ft_getopt(cfg, 'avgovertime', 'no');
cfg.design      = ft_getopt(cfg, 'design',      '');

% get the design from the information in cfg and data.
if ~isfield(cfg,'design') || isempty(cfg.design)
  error('you should provide a design matrix in the cfg');
end

if ~isfield(cfg,'resample')
    cfg.resample = 0; %default is to not resample to match trial numbers
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data bookkeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ndata = numel(varargin);

% set the parameter to default powspctrm only if present in the data
if isempty(cfg.parameter) && isfield(varargin{1}, 'powspctrm')
  cfg.parameter = 'powspctrm';
elseif isempty(cfg.parameter)
  error('You need to specify a cfg.parameter, because the default (powspctrm) is not present in the input data');
end

% check if the input data is valid for this function
hastime  = false(Ndata,1);
hasparam = false(Ndata,1);
for i=1:Ndata
  varargin{i} = ft_checkdata(varargin{i}, 'datatype', 'freq', 'feedback', 'no');
  hastime(i)  = isfield(varargin{i}, 'time');
  haschan(i)  = ~isempty(strfind(varargin{i}.dimord, 'chan')) ...
                && numel(varargin{i}.label) > 1;
  hasparam(i) = isfield(varargin{i}, cfg.parameter);
end

if sum(hastime)~=Ndata && sum(hastime)~=0
  error('the input data structures should either all contain a time axis, or none of them should');
end
hastime = sum(hastime)==Ndata;

if sum(hasparam)~=Ndata
  error('the input data structures should all contain the parameter %s', cfg.parameter);
end

haschan = sum(haschan)==Ndata;

% check whether channel neighbourhood information is needed and present
if isfield(cfg, 'correctm') && strcmp(cfg.correctm, 'cluster') ...
    && ~strcmp(cfg.avgoverchan, 'yes') && haschan
  cfg = ft_checkconfig(cfg, 'required', {'neighbours'});    
end

% get frequency, latency and channels which are present in all subjects
fmin = -inf;
fmax =  inf;
tmin = -inf;
tmax =  inf;
for i=1:Ndata
  fmin = max(fmin, varargin{i}.freq(1));
  fmax = min(fmax, varargin{i}.freq(end));
  if hastime
    tmin = max(tmin, varargin{i}.time(1));
    tmax = min(tmax, varargin{i}.time(end));
  end
  if i==1
    % FIXME deal with channelcmb
    if isfield(varargin{i}, 'labelcmb')
      error('support for data containing linearly indexed bivariate quantities, i.e. containing a ''labelcmb'' is not yet implemented');
    else
      chan = varargin{i}.label;
    end
  else
    chan = varargin{i}.label(ismember(varargin{i}.label, chan));
  end
end

if ischar(cfg.frequency) && strcmp(cfg.frequency, 'all')
  cfg.frequency = [fmin fmax];
elseif ischar(cfg.frequency)
  error('unsupported value for ''cfg.frequency''');
end

% overrule user-specified settings
cfg.frequency = [max(cfg.frequency(1), fmin), min(cfg.frequency(2), fmax)];
fprintf('computing statistic over the frequency range [%1.3f %1.3f]\n', cfg.frequency(1), cfg.frequency(2));

if hastime
  if ischar(cfg.latency) && strcmp(cfg.latency, 'all')
    cfg.latency = [tmin tmax];
  elseif ischar(cfg.latency)
    error('unsupported value for ''cfg.latency''');
  end
  
  % overrule user-specified settings
  cfg.latency = [max(cfg.latency(1), tmin), min(cfg.latency(2), tmax)];
  fprintf('computing statistic over the time range [%1.3f %1.3f]\n', cfg.latency(1), cfg.latency(2));
end

% only do those channels present in the data
cfg.channel = ft_channelselection(cfg.channel, chan);

if ~ischar(cfg.trials)
  if Ndata==1
    varargin{1} = ft_selectdata(varargin{1}, 'rpt', cfg.trials);
  else
    error('subselection of trials is only allowed with a single data structure as input');
  end
end

% intersect the data and combine it into one structure
if hastime
  if haschan
    data =  ft_selectdata(varargin{:}, 'param', cfg.parameter, 'avgoverrpt', false, ...
      'toilim', cfg.latency, 'avgovertime', cfg.avgovertime, ...
      'foilim',  cfg.frequency, 'avgoverfreq', cfg.avgoverfreq, ...
      'channel', cfg.channel, 'avgoverchan', cfg.avgoverchan);
  else
    data =  ft_selectdata(varargin{:}, 'param', cfg.parameter, 'avgoverrpt', false, ...
    'toilim', cfg.latency, 'avgovertime', cfg.avgovertime, ...
    'foilim',  cfg.frequency, 'avgoverfreq', cfg.avgoverfreq, ...
    'avgoverchan', cfg.avgoverchan);
  end
else
  if haschan
    data =  ft_selectdata(varargin{:}, 'param', cfg.parameter, 'avgoverrpt', false, ...
      'foilim',  cfg.frequency, 'avgoverfreq', cfg.avgoverfreq, ...
      'channel', cfg.channel, 'avgoverchan', cfg.avgoverchan);
  else
    data =  ft_selectdata(varargin{:}, 'param', cfg.parameter, 'avgoverrpt', false, ...
      'foilim',  cfg.frequency, 'avgoverfreq', cfg.avgoverfreq, ...
      'avgoverchan', cfg.avgoverchan);
  end
end

% keep the sensor info, just in case
if isfield(varargin{1}, 'elec')
  data.elec = varargin{1}.elec;
elseif isfield(varargin{1}, 'grad')
  data.grad = varargin{1}.grad;
end

% ensure that we don't touch this any more
clear varargin;

%equate condtions by upsampling deficiencies?
if cfg.resample 
    dat = data.(cfg.parameter);
    datsize = size(dat);
    %find deficient conditons
    labels = unique(cfg.design);
    ntrials = arrayfun(@(x)(sum(x==cfg.design)),labels);
    
    maxsamp = max(ntrials);
    newdesign = cfg.design;
    newdat = dat;
    newtrialinfo = data.trialinfo;
    for isamp = 1:length(labels)
        idx = find(labels(isamp) == cfg.design);
        if maxsamp - length(idx) ~=0
            fprintf('resampling %d trials to label %d\n',maxsamp - length(idx), labels(isamp));
            ridx = randsample(idx,maxsamp-length(idx),true);
            rptdim = find(strcmp('rpt',regexp(data.dimord,'_','split')));
            tempdat = reshape(dat(ridx,:),[length(ridx),datsize(2:end)]);
            newdat= cat(rptdim,newdat,tempdat);
            newdesign = cat(2,newdesign,cfg.design(ridx));
            newtrialinfo = cat(rptdim,newtrialinfo,data.trialinfo(ridx,:));
        end
    end
    
    data.(cfg.parameter) = newdat;
    data.trialinfo = newtrialinfo;
    cfg.design = newdesign;

end

% create the 'dat' matrix here
dat        = data.(cfg.parameter);
siz        = size(dat);
dimtok     = tokenize(data.dimord, '_');
% check for occurence of channel dimension
chandim     = find(ismember(dimtok, {'chan'}));
if isempty(chandim)
  dimtok(3:end+1) = dimtok(2:end);
  dimtok{2} = 'chan';
  siz = [siz(1) 1 siz(2:end)];
  dat = reshape(dat, siz);
end
rptdim     = find(ismember(dimtok, {'rpt' 'subj' 'rpttap'}));
permutevec = [setdiff(1:numel(siz), rptdim) rptdim];       % permutation vector to put the repetition dimension as last dimension
reshapevec = [prod(siz(permutevec(1:end-1))) siz(rptdim) 1]; % reshape vector to reshape into 2D
dat        = reshape(permute(dat, permutevec), reshapevec);% actually reshape the data

reduceddim = setdiff(1:numel(siz), rptdim);
cfg.dim    = [siz(reduceddim) 1];   % store dimensions of the output of the statistics function in the cfg
cfg.dimord = '';
for k = 1:numel(reduceddim)
  cfg.dimord = [cfg.dimord, '_', dimtok{reduceddim(k)}];
end
cfg.dimord = cfg.dimord(2:end); % store the dimord of the output in the cfg

if size(cfg.design,2)~=size(dat,2)
  error('the number of observations in the design does not match the number of observations in the data');
end

stat = rmfield(data,cfg.parameter);
stat.dimord = cfg.dimord;
stat.dim = cfg.dim;
stat.cfg = cfg;    

% do the general cleanup and bookkeeping at the end of the function
ft_postamble trackconfig
ft_postamble callinfo
ft_postamble previous varargin
ft_postamble history stat
ft_postamble savevar stat
