function [outdata] = nk_ft_read_train_data(cfg,dirs,exper)

% reads data files for a particular subject into 'outdata'
%
%   input:
%       cfg.sub = subject identifier
%       cfg.cname = classifier type
%       cfg.frequency = frequency range used in classification
%       cfg.conds = conditions classified
%       dirs = dirs struc, must include dirs.saveDataProc
%       exper = exper struc, must include exper.subjects
%
%   output:
%       outdata = cell array of stat structs read in from file
%           

%set defaults
cfg.avgoverfreq = ft_getopt(cfg, 'avgoverfreq', 'no');
cfg.avgovertime = ft_getopt(cfg, 'avgovertime', 'no');


if ~isfield(dirs,'saveDirProc') 
    error('dirs struc needs ''saveDirProc'' field');
end
if ~isfield(exper,'subjects')
    error('exper struc needs ''subjects'' field');
end

%get sub string
sub = strcmp(exper.subjects,cfg.sub);
if sum(sub) > 1
    error('non-unique subject specifier');
else
    sub = exper.subjects{sub};
end

%create vsstr
tempstr = {};
for iconds = 1:length(cfg.conds)
    tempstr{iconds} = sprintf('%s+',cfg.conds{iconds}{:});
    tempstr{iconds} = tempstr{iconds}(1:end-1);
end
vsstr = sprintf('%sVs%s',tempstr{:});

if strcmp(cfg.avgoverfreq,'yes')
    datdir = fullfile(dirs.saveDirProc, sub, sprintf('pow_classify_%s_%d_%d_avg', cfg.cname, cfg.frequency));
else
    datdir = fullfile(dirs.saveDirProc, sub, sprintf('pow_classify_%s_%d_%d', cfg.cname, cfg.frequency));
end
if strcmp(cfg.avgovertime,'yes');
    datfiles = dir([datdir filesep sprintf('pow_classify_%s_%s_%d_%d_*_*_avg.mat', cfg.cname, vsstr,cfg.frequency)]);
else
    datfiles = dir([datdir filesep sprintf('pow_classify_%s_%s_%d_%d_*_*.mat', cfg.cname, vsstr,cfg.frequency)]);
    datfiles = datfiles(cellfun(@(x) isempty(x), regexp({datfiles.name},'.*avg.mat')));
end
    
datfiles = {datfiles.name};

if length(datfiles) < 1
    error('No mat files found');
end

for imat = 1:length(datfiles)
    
    if cfg.statonly 
        statistic = [];
%        load(fullfile(datdir,datfiles{imat}), 'statistic');
        load(fullfile(datdir,datfiles{imat}), 'stat');
        outdata(imat) = stat.statistic;
    else
        stat = [];
        load(fullfile(datdir,datfiles{imat}), 'stat');
        outdata(imat) = stat;
    end
    
end


    