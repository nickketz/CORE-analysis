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
    
    [data_pow] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow');
    
    % Change in freq relative to baseline using absolute power
    
    cfg_fb = [];
    cfg_fb.baseline = [-0.3 -0.1];
    cfg_fb.baselinetype = 'absolute';
    
    %data_freq_orig = data_freq;
    
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
else %outherwise ana, exper and data_freq must be included
    indata = varargin{1};
    if sum(isfield(indata,{'data_freq','exper','ana'})) ~= 3
        error('Must specify an infile otherwise data_freq, exper and ana must be included as fields in a input struct after the cfg struct');
    else
        data_freq = indata.data_freq;
        ana = indata.ana;
        exper = indata.exper;
    end    
end


%% train classifier on faces and scenes
%must have dml toolbox added to path, path of the external toolboxes
%included with fieldtrip

data1 = data_freq.Timg_Face.sub(subNo).ses.data;
data0 = data_freq.Timg_Scene.sub(subNo).ses.data;

% specifiy classifier details

cfg_cd         = [];
cfg_cd.layout  = ft_prepare_layout([],ana);
cfg_cd.latency = cfg.latency;%[0 .5];
cfg_cd.method  = 'crossvalidate';
cfg_cd.design  = cfg.design;%[ones(size(data0.powspctrm,1),1); 2*ones(size(data1.powspctrm,1),1)]';
cfg_cd.mva     = cfg.mva;%{dml.standardizer dml.enet('family','binomial','alpha',0.2)};
stat        = ft_freqstatistics(cfg,data0,data1);
