function [stat] = core_ft_pow_enet(cfg,varargin)

% CORE specfic function to search subject powspctrm for optimal time period
% in which to run classification on faces and scenes.  Designed to run on
% multiple cores simultaneously by specifying cfg.infile and cfg.outfile
%
%   input:
%       cfg.infile      = adFile to specify ft strcut
%       cfg.outfile     = file to save results to
%       cfg.subNo       = subject number to run process on
%       cfg.latency     = time period to run classifier on
%
%   output:
%       stat    = data structure resulting from crossvalidated
%       classification, if cfg.outfile is specified this stat struct is
%       saved out
%

if isfield(cfg,'infile') %if infile specified load analysis details
    adFile = cfg.infile;
    %adFile = '/data/projects/oreillylab/nick/CORE_EEG/data/eeg/1000to1700/ft_data/EIMG_Red_Scene_Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
    [exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,true);
    
    files.figFontName = 'Helvetica';
    files.figPrintFormat = 'dpng';
    files.figPrintRes = 150;
    
    %files.figPrintFormat = 'tiff';
    %files.figPrintRes = 1000;
    
    % set up channel groups
    
    % pre-defined in this function
    ana = mm_ft_elecGroups(ana);
    
    % list the event values to analyze; specific to each experiment
    
    ana.eventValues = {exper.eventValues};
    
    % make sure ana.eventValues is set properly
    if ~iscell(ana.eventValues{1})
        ana.eventValues = {ana.eventValues};
    end
    if ~isfield(ana,'eventValues') || isempty(ana.eventValues{1})
        ana.eventValues = {exper.eventValues};
    end
    
    % load in the subject data
    
    [data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow');
    
    if isfield(cfg,'baselinecorrect')
        if cfg.baselinecorrect
            % Change in freq relative to baseline using absolute power
            cfg_fb = [];
            cfg_fb.baseline = [-0.3 -0.1];
            cfg_fb.baselinetype = 'absolute';
            
            for sub = 1:length(exper.subjects)
                for ses = 1:length(exper.sessions)
                    for typ = 1:length(ana.eventValues)
                        for evVal = 1:length(ana.eventValues{typ})
                            fprintf('%s, %s, %s, ',exper.subjects{sub},exper.sessions{ses},ana.eventValues{typ}{evVal});
                            data_freq.(ana.eventValues{typ}{evVal}).sub(sub).ses(ses).data = ft_freqbaseline(cfg_fb,data_freq.(ana.eventValues{typ}{evVal}).sub(sub).ses(ses).data);
                        end
                    end
                end
            end
        end
    end
    
else %outherwise ana, exper and data_freq must be included
    if isempty(varargin)
        error('Must specify an infile otherwise data_freq must be included as input parameter');
    else
        data_freq = varargin{1};
    end    
end


%% train classifier on specified conditions
%must have dml toolbox added to path, path of the external toolboxes
%included with fieldtrip
design = [];
data = cell(1,length(cfg.conds));
subNo = cfg.subNo;
for iconds = 1:length(cfg.conds)
    data{iconds} = data_freq.(cfg.conds{iconds}).sub(subNo).ses.data;
    %make design matrix while we're at it
    design = [design; iconds*ones(size(data{iconds}.powspctrm,1),1)];
end

% specifiy classifier details

cfg_cd         = [];
cfg_cd.latency = cfg.latency;%[0 .5];
cfg_cd.frequency = cfg.frequency;
cfg_cd.method = 'crossvalidate';
cfg_cd.design = design';%[ones(size(data0.powspctrm,1),1); 2*ones(size(data1.powspctrm,1),1)]';
cfg_cd.mva     = cfg.mva; %{dml.standardizer dml.enet('family','binomial','alpha',0.2)};
cfg_cd.nfolds  = cfg.nfolds;

% run classifier 
stat           = ft_freqstatistics(cfg_cd,data{:});

%save data?
if isfield(cfg,'savedata') && isfield(cfg,'infile')
    if cfg.savedata
        
        %create outfile str
        outdir = fullfile(dirs.saveDirProc, exper.subjects{cfg.subNo}, sprintf('pow_classify_%s_%d_%d',cfg_cd.name,cfg_cd.frequency(1)*1000,cfg_cd.frequency(2)*1000));
        if ~exist(outdir,'dir');
            eval(['!mkdir -p ' outdir]);
        end
        vsstr = sprintf('%svs',cfg_cd.conds{:});
        vsstr = vsstr(1:end-2);
        outfile = fullfile(outdir,sprintf('pow_classify_%s_%s_%d_%d_%d_%d.mat',cfg_cd.name, vsstr,cfg_cd.frequency,cfg_cd.latency*1000));
        if exist(outfile,'file')
            warning('Data file already exists!! Overwriting!');            
            save(outfile,stat);
        end
    end
end
