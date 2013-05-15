% post segmentation analysis scripts for CORE experiment

%% load the analysis details

%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to1700/ft_data/Eimg_Red_Scene_Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to1700/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to1700/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to1700/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to1700/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1680_3_50/analysisDetails.mat';

%1000to2500
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50_BACKUP/analysisDetails.mat';
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails.mat';
% post classifier output
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2500/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postClass.mat';

%1000to2000
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails.mat';
%post-classifier - performance selected on crossvalidated training set
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postClass.mat';
%post-classifier - verified crossvalidation selection
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postClass_verify.mat';
%post-classifier - performanced selected on crossvalidated Green conditions
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postGreenClass.mat';
%post-classifer - performance selected on testset
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postTestClass.mat';
%post-classifier - performance selected on testset auc sumdiff
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postTestClassAUC.mat';
%post-classifier - performance selected on testset auc maxdiff
%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postTestClassAUC_maxdiff.mat';
%maxdiff relabled to represented origcat-countercat
adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postTestClassAUC_maxdiff_relabel.mat';


[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);

files.figFontName = 'Helvetica';
files.figPrintFormat = 'png';
files.figPrintRes = 300;
files.saveFigs = 1;

%files.figPrintFormat = 'tiff';
%files.figPrintRes = 1000;

%% set up channel groups

% pre-defined in this function
ana = mm_ft_elecGroups(ana);

%% list the event values to analyze; specific to each experiment

ana.eventValues = {exper.eventValues};

ana.eventValues{1} = cat(2,ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word_.*Comb_Succ$'))));
% ana.eventValues{1} = {'Word_Green_Comb_Succ_Rem','Word_Green_Comb_Succ_Forg',...
%           'Word_Blue_Comb_Rem','Word_Blue_Comb_Forg',...
%           'Word_Red_Comb_Rem','Word_Red_Comb_Forg'};
%ana.eventValues{1} = cat(2,ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word_.*_Comb_CongCrit$'))));
% 
% %add newsucc to tail of Word conditions and remove other condition names
% tempvals = ana.eventValues{1};
% newstr = 'Comb_Succ';
% for iword = 1:length(tempvals)
%     if ~isempty(strfind(tempvals{iword},newstr))
%         tempvals{iword} = tempvals{iword};
%     else
%         tempvals{iword} = [];
%     end
% end
% tempvals = tempvals(~cellfun('isempty',tempvals));
% ana.eventValues = {tempvals};

% make sure ana.eventValues is set properly
if ~iscell(ana.eventValues{1})
  ana.eventValues = {ana.eventValues};
end
if ~isfield(ana,'eventValues') || isempty(ana.eventValues{1})
  ana.eventValues = {exper.eventValues};
end

%% load in the subject data
%[data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow',1);
[data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow',0);


%% find poor performing subjects on initial learning and kick them out
subacc = nan(length(exper.subjects),1);
for isub = 1:length(exper.subjects)
    temp = CORE_datread(exper.subjects{isub},0,dirs);
    subacc(isub,1) = temp.repac(end);
end


%% decide who to kick out based on trial counts

% Subjects with bad behavior
exper.badBehSub = {};

% exclude subjects with low event counts
[exper] = mm_threshSubs(exper,ana,1);

%% creat diff conditions
%diffconds =
%diffconds = {{'Word_Red_Comb_Succ','Word_Green_Comb_Succ'},{'Word_Blue_Comb_Succ','Word_Green_Comb_Succ'}};
diffconds = {{'Word_Red_Comb','Word_Green_Comb'},{'Word_Blue_Comb','Word_Green_Comb'}};
[data_freq, ana] = nk_conddiff(data_freq, ana, diffconds,'powspctrm'); 

%% baseline correct

cfg_fb = [];
cfg_fb.baseline = [-.3 -.1];
cfg_fb.baselinetype = 'absolute';
data_freq = nk_ft_baselinecorrect(data_freq,ana,exper,cfg_fb);


%% get the grand average

% set up strings to put in grand average function
cfg_ana = [];
cfg_ana.is_ga = 0;
cfg_ana.conditions = ana.eventValues;
cfg_ana.data_str = 'data_freq';
cfg_ana.sub_str = mm_ft_catSubStr(cfg_ana,exper);

cfg_ft = [];
cfg_ft.keepindividual = 'no';
for ses = 1:length(exper.sessions)
  for typ = 1:length(ana.eventValues)
    for evVal = 1:length(ana.eventValues{typ})
      %tic
      fprintf('Running ft_freqgrandaverage on %s...',ana.eventValues{typ}{evVal});
      ga_freq.(ana.eventValues{typ}{evVal})(ses) = eval(sprintf('ft_freqgrandaverage(cfg_ft,%s);',cfg_ana.sub_str.(ana.eventValues{typ}{evVal}){ses}));
      fprintf('Done.\n');
      %toc
    end
  end
end


%% plot the conditions - simple

cfg_ft = [];
cfg_ft.ylim = [3 8];
cfg_ft.zlim = 'maxmin';

cfg_ft.showlabels = 'yes';
cfg_ft.colorbar = 'yes';
cfg_ft.interactive = 'yes';
cfg_ft.showoutline = 'yes';
cfg_ft.layout = ft_prepare_layout([],ana);
for typ = 1:length(ana.eventValues)
  for evVal = 1:length(ana.eventValues{typ})
    figure
    ft_multiplotTFR(cfg_ft,ga_freq.(ana.eventValues{typ}{evVal}));
    set(gcf,'Name',sprintf('%s',ana.eventValues{typ}{evVal}))
  end
end

%% subplots of each subject's power spectrum

cfg_plot = [];
%cfg_plot.rois = {{'LAS','RAS'},{'LPS','RPS'}};
cfg_plot.rois = {{'FS'},{'PS'}};
%cfg_plot.roi = {'E124'};
%cfg_plot.roi = {'RAS'};
%cfg_plot.roi = {'LPS','RPS'};
%cfg_plot.roi = {'LPS'};
cfg_plot.excludeBadSub = 0;
cfg_plot.numCols = 5;

% outermost cell holds one cell for each ROI; each ROI cell holds one cell
% for each event type; each event type cell holds strings for its
% conditions
cfg_plot.condByROI = repmat({{'Word_Blue_Face_Succ'}},size(cfg_plot.rois));
% cfg_plot.condByROI = {...
%   {{'TH','NT','B'}},...
%   {{'TH','NT','B'}}};

cfg_ft = [];
cfg_ft.colorbar = 'yes';
cfg_ft.zlim = [-2 2];
cfg_ft.parameter = 'powspctrm';
cfg_plot.condMethod = 'single';

for r = 1:length(cfg_plot.rois)
  cfg_plot.roi = cfg_plot.rois{r};
  cfg_plot.conditions = cfg_plot.condByROI{r};
  
  mm_ft_subjplotTFR(cfg_ft,cfg_plot,ana,exper,data_freq);
end

%% make some GA plots

cfg_ft = [];
cfg_ft.colorbar = 'yes';
cfg_ft.interactive = 'yes';
cfg_ft.showlabels = 'yes';
%cfg_ft.xlim = 'maxmin'; % time
%cfg_ft.ylim = 'maxmin'; % freq
% cfg_ft.zlim = 'maxmin'; % pow
%cfg_ft.xlim = [.5 1.0]; % time
cfg_ft.ylim = [3 20]; % freq
%cfg_ft.ylim = [8 12]; % freq
%cfg_ft.ylim = [12 28]; % freq
%cfg_ft.ylim = [28 50]; % freq
%cfg_ft.zlim = [-100 100]; % pow
cfg_ft.zlim = 'maxmin';
%cfg_ft.zlim = [-1 1]; % pow

cfg_ft.parameter = 'powspctrm';

cfg_plot = [];
cfg_plot.plotTitle = 1;

%cfg_plot.rois = {{'FS'},{'LAS','RAS'},{'LPS','RPS'}};
%cfg_plot.rois = {{'FS'},{'PS'}};
%cfg_plot.rois = {'E71'};
cfg_plot.rois = {'all'};

cfg_plot.is_ga = 1;
% outermost cell holds one cell for each ROI; each ROI cell holds one cell
% for each event type; each event type cell holds strings for its
% conditions
cfg_plot.condByROI = repmat({ana.eventValues},size(cfg_plot.rois));

%%%%%%%%%%%%%%%
% Type of plot
%%%%%%%%%%%%%%%

%cfg_plot.ftFxn = 'ft_singleplotTFR';

% cfg_plot.ftFxn = 'ft_topoplotTFR';
% %cfg_ft.marker = 'on';
% cfg_ft.marker = 'labels';
% cfg_ft.markerfontsize = 9;
% cfg_ft.comment = 'no';
% %cfg_ft.xlim = [0.5 0.8]; % time
% cfg_plot.subplot = 1;
% cfg_ft.xlim = [0 1.0]; % time

cfg_plot.ftFxn = 'ft_multiplotTFR';
cfg_ft.showlabels = 'yes';
cfg_ft.comment = '';

for r = 1:length(cfg_plot.rois)
  cfg_plot.roi = cfg_plot.rois{r};
  cfg_plot.conditions = cfg_plot.condByROI{r};
  
  mm_ft_plotTFR(cfg_ft,cfg_plot,ana,files,dirs,ga_freq);
end

%% plot the contrasts

cfg_plot = [];
cfg_plot.plotTitle = 1;

% comparisons to make
%cfg_plot.conditions = {{'Word_Blue_Face_CongCrit','Word_Red_Face_CongCrit'}};
%cfg_plot.conditions = {{'Word_Blue_Face_Switch','Word_Green_Face_Switch'}};
%cfg_plot.conditions = {{'Word_Red_Comb_Switch','Word_Blue_Comb_Switch'}};
%cfg_plot.conditions = {{'Word_Blue_Comb_Succ','Word_Green_Comb_Succ'}};
cfg_plot.conditions = {{'Word_Blue_Comb_SuccvsWord_Green_Comb_Succ','Word_Red_Comb_SuccvsWord_Green_Comb_Succ'}};
%cfg_plot.conditions = {{'Word_Blue_Comb_CongCrit','Word_Green_Comb_CongCrit'}};
%cfg_plot.conditions = {{'Word_Blue_Comb_Succ_Rem','Word_Blue_Comb_Succ_Forg'}};
%cfg_plot.conditions = {{'Word_Green_Comb_Switch_Rem','Word_Green_Comb_Switch_Forg'}};

%cfg_plot.conditions = {'all'};

cfg_ft = [];
cfg_ft.xlim = [0 1]; % time
%cfg_ft.ylim = [3 8]; % freq
cfg_ft.ylim = [3 20]; % freq
%cfg_ft.ylim = [12 28]; % freq
%cfg_ft.ylim = [28 50]; % freq
cfg_ft.zparam = 'powspctrm';
cfg_ft.zlim = 'maxmin';%[-1 1]; % pow

cfg_ft.interactive = 'yes';
cfg_ft.colormap = jet;
cfg_ft.colorbar = 'yes';

%%%%%%%%%%%%%%%
% Type of plot
%%%%%%%%%%%%%%%

%cfg_plot.ftFxn = 'ft_singleplotTFR';
cfg_plot.ftFxn = 'ft_topoplotTFR';
%cfg_plot.rois = 'noEyeABH';
%cfg_ft.marker = 'on';
cfg_ft.marker = 'labels';
cfg_ft.markerfontsize = 9;
cfg_ft.comment = 'no';
%cfg_ft.xlim = [0.5 0.8]; % time
cfg_plot.subplot = 1;
%cfg_ft.xlim = [0 1.25]; % time
%cfg_ft.xlim = (0:0.05:1.0); % time
%cfg_plot.roi = {'PS'};

% cfg_plot.ftFxn = 'ft_multiplotTFR';
% cfg_ft.showlabels = 'yes';
% cfg_ft.comment = '';

mm_ft_contrastTFR(cfg_ft,cfg_plot,ana,files,dirs,ga_freq);

%% cluster statistics

files.figPrintFormat = 'fig';
files.saveFigs = 0;

cfg_ft = [];
cfg_ft.avgoverchan = 'no';
cfg_ft.avgovertime = 'no';
cfg_ft.avgoverfreq = 'yes';
%cfg_ft.avgoverfreq = 'no';

cfg_ft.parameter = 'powspctrm';

% debugging
%cfg_ft.numrandomization = 5000;

cfg_ft.numrandomization = 500;
cfg_ft.clusteralpha = .01;
cfg_ft.alpha = .1;

cfg_ana = [];
cfg_ana.roi = 'noEyeABH';
%cfg_ana.conditions = {{'TH','NT'}};
%cfg_ana.conditions = {'Word_Blue_Face_Switch','Word_Green_Face_Switch'};
%cfg_ana.conditions = {'Word_Red_Comb_Switch','Word_Blue_Comb_Switch'};
%cfg_ana.conditions = {'Word_Blue_Comb_CongCrit','Word_Green_Comb_CongCrit'};
%cfg_ana.conditions = {'Word_Blue_Comb_Succ_Rem','Word_Blue_Comb_Succ_Forg'};

%cfg_ana.conditions = {'Word_Blue_Comb','Word_Green_Comb'};


%cfg_ana.conditions = {'Word_Blue_Comb_Succ','Word_Red_Comb_Succ'};
cfg_ana.conditions = {'Word_Red_Comb_Succ','Word_Green_Comb_Succ'};
%cfg_ana.conditions = {'Word_Blue_Comb_Succ','Word_Green_Comb_Succ'};
%cfg_ana.conditions = {'Word_Red_Comb_SuccvsWord_Green_Comb_Succ','Word_Blue_Comb_SuccvsWord_Green_Comb_Succ'};

%cfg_ana.conditions = {'Word_Red_Scene_Succ','Word_Green_Scene_Succ'};
%cfg_ana.conditions = {'Word_Red_Face_Succ','Word_Blue_Face_Succ'};
%cfg_ana.conditions = {'Word_Blue_Face_Succ','Word_Red_Face_Succ'};

%cfg_ana.conditions = {'Word_Blue_Comb_Succ_Rem','Word_Green_Comb_Succ_Rem'};

%cfg_ana.conditions = {'Word_Blue_Face_CongCrit','Word_Green_Face_CongCrit'};

%cfg_ana.frequencies = [8 12];
cfg_ana.frequencies = [3 8; 8 12; 12 30; 30 50];
cfg_ana.latencies = [0.2 1];
%cfg_ana.latencies = [0 0.5; 0.5 1.0];
%culsteriter.m
for lat = 1:size(cfg_ana.latencies,1)
    cfg_ft.latency = cfg_ana.latencies(lat,:);
    for fr = 1:size(cfg_ana.frequencies,1)
        cfg_ft.frequency = cfg_ana.frequencies(fr,:);
        
        [stat_clus] = mm_ft_clusterstatTFR(cfg_ft,cfg_ana,exper,ana,dirs,data_freq);  
%         mydir = fullfile(dirs.saveDirProc,['tfr_stat_clus_' num2str(cfg_ft.latency(1)*1000) '_' num2str(cfg_ft.latency(2)*1000)]);
%         myfile = ['tfr_stat_clus_' cfg_ana.conditions{1} 'vs' cfg_ana.conditions{2} '_' sprintf('%.01f_%.01f',cfg_ft.frequency) '_' num2str(cfg_ft.latency(1)*1000) '_' num2str(cfg_ft.latency(2)*1000) '.mat'];
%         load(fullfile(mydir,myfile));
        
    end
end
cfg_plot.frequency = cfg_ft.frequency;
cfg_plot.latency = cfg_ft.latency;

%% make average plot for significant elecs

cfg_ft = [];
cfg_ft.alpha = .1;

cfg_ft.avgoverfreq = 'yes';
cfg_ft.avgovertime = 'yes';
cfg_ft.interactive = 'yes';
cfg_ft.mask = 'yes';
cfg_ft.highlightsizeseries  = repmat(15,6,1);

cfg_ft.maskstyle = 'opacity';
cfg_ft.transp = 1;  
%cfg_ft.maskstyle = 'saturation';
cfg_ft.maskalpha = 0.1;
cfg_ft.layout = ft_prepare_layout([],ana);
%cfg_ft.highlightseries ={'numbers','numbers','numbers','numbers','numbers','numbers'};
cfg_ft.highlightcolorpos = [1 1 1];
vsstr = fieldnames(stat_clus);

for iclus = 1:1%length(stat_clus.(vsstr{1}).posclusters)
    if stat_clus.(vsstr{1}).posclusters(iclus).prob < cfg_ft.alpha
        cfg_ft.clusnum = iclus;
        outdata = nk_ft_avgclustplot(stat_clus,cfg_plot,cfg_ft,dirs,files,1);        
        % plot cluster average power over time
        cfg_ft.time = [-1 1.5];       
        cfg_ft.conds = cat(2,cfg_ana.conditions);
        cfg_ft.conds = ana.eventValues{1};
        for icond = 1:length(cfg_ft.conds)
            cond1 = tokenize(cfg_ft.conds{icond},'_');
            cfg_plot.colors(icond,:) = rgb(cond1{2});
        end        
        outdata = nk_ft_avgpowerbytime(data_freq,stat_clus,cfg_plot,cfg_ft,dirs,files,0);
        %outdatafreq = nk_ft_avgpowerbyfreq(data_freq,stat_clus,cfg_plot,cfg_ft,dirs,files,1);
    else
        continue;
    end
end

%% plot the cluster statistics

%files.saveFigs = 0;

%cfg_ft = [];
%cfg_ft.alpha = .12;

cfg_plot = [];
cfg_plot.conditions = cfg_ana.conditions;
cfg_plot.frequencies = cfg_ana.frequencies;
cfg_plot.latencies = cfg_ana.latencies;

% not averaging over frequencies - only works with ft_multiplotTFR
%files.saveFigs = 0;
%cfg_ft.avgoverfreq = 'yes';
%cfg_ft.avgoverfreq = 'no';
cfg_ft.interactive = 'yes';
cfg_plot.mask = 'yes';
cfg_ft.showoutline = 'yes';
cfg_ft.maskstyle = 'saturation';
cfg_ft.maskalpha = 0.1;
cfg_plot.ftFxn = 'ft_multiplotTFR';
% http://mailman.science.ru.nl/pipermail/fieldtrip/2009-July/002288.html
% http://mailman.science.ru.nl/pipermail/fieldtrip/2010-November/003312.html

for lat = 1:size(cfg_plot.latencies,1)
  cfg_ft.latency = cfg_plot.latencies(lat,:);
  for fr = 1:size(cfg_plot.frequencies,1)
    cfg_ft.frequency = cfg_plot.frequencies(fr,:);
    
    mm_ft_clusterplotTFR(cfg_ft,cfg_plot,ana,files,dirs);
  end
end


%% descriptive statistics: ttest

%cfg_ana = [];
vsstr = fieldnames(stat_clus);
vsstr = vsstr{1};
ind = find(stat_clus.(vsstr).posclusterslabelmat==1);
[x,y,z] = ind2sub(size(stat_clus.(vsstr).posclusterslabelmat),ind);
% define which regions to average across for the test
%cfg_ana.rois = {{'PS'},{'FS'},{'LPS','RPS'},{'PS'},{'PS'}};
cfg_ana.rois = {stat_clus.(vsstr).label(unique(x))};
% define the times that correspond to each set of ROIs
%cfg_ana.latencies = [0.2 0.4; 0.6 1.0; 0.5 0.8; 0.5 1.0; 0.5 1.0];
cfg_ana.latencies = stat_clus.(vsstr).time(unique(z));
% define the frequencies that correspond to each set of ROIs
%cfg_ana.frequencies = [3 8; 3 8; 3 8; 3 8; 8 12];
cfg_ana.frequencies = stat_clus.(vsstr).cfg.frequency;

%cfg_plot.conditions = {{'THR','THF'},{'NTR','NTF'},{'THR','NTR'},{'THF','NTF'}};
cfg_ana.conditions = {'Word_Redbgt_Comb_Succ','Word_Green_Comb_Succ'};
%cfg_ana.conditions = {{'TH','NT'},{'TH','B'},{'NT','B'}};
%cfg_ana.conditions = {'all'};

% set parameters for the statistical test
cfg_ft = [];
cfg_ft.avgovertime = 'yes';
cfg_ft.avgoverchan = 'yes';
cfg_ft.avgoverfreq = 'yes';
cfg_ft.parameter = 'powspctrm';
cfg_ft.correctm = 'fdr';

cfg_plot = [];
cfg_plot.individ_plots = 0;
cfg_plot.line_plots = 0;
% line plot parameters
%cfg_plot.ylims = repmat([-1 1],size(cfg_ana.rois'));
cfg_plot.ylims = repmat([-100 100],size(cfg_ana.rois'));

for r = 1:length(cfg_ana.rois)
  cfg_ana.roi = cfg_ana.rois{r};
  cfg_ft.latency = cfg_ana.latencies(r,:);
  cfg_ft.frequency = cfg_ana.frequencies(r,:);
  cfg_plot.ylim = cfg_plot.ylims(r,:);
  
  mm_ft_ttestTFR(cfg_ft,cfg_ana,cfg_plot,exper,ana,files,dirs,data_freq);
end
