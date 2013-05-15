%% Make plots and do analyses for timelocked EEG (ERPs)

% See Maris & Oostenveld (2007) for info on nonparametric statistics

% initialize the analysis structs
exper = struct;
files = struct;
dirs = struct;
ana = struct;

%% Experiment-specific setup

exper.name = 'CORE_EEG';

exper.sampleRate = 250;

% pre- and post-stimulus times to read, in seconds (pre is negative)
exper.prepost = [-1.0 2.0];

% equate the number of trials across event values?
exper.equateTrials = 0;

% type of NS file for FieldTrip to read; raw or sbin must be put in
% dirs.dataroot/ns_raw; egis must be put in dirs.dataroot/ns_egis
exper.eegFileExt = 'egis';
%exper.eegFileExt = 'raw';

% types of events to find in the NS file; these must be the same as the
% events in the NS files
%exper.eventValues = sort({'TIMG','EIMG','WORD'});
exper.eventValues = sort({'Timg_Scene','Timg_Face',...
    'Word_Green_Scene','Word_Green_Face','Eimg_Green_Face','Eimg_Green_Scene',...
    'Word_Blue_Scene','Word_Blue_Face','Eimg_Blue_Scene','Eimg_Blue_Face',...
    'Word_Red_Scene','Word_Red_Face','Eimg_Red_Scene','Eimg_Red_Face'...
    });
    

% combine some events into higher-level categories
%exper.eventValuesExtra.toCombine = {{'CHSC','CHSI'},{'SHSC','SHSI'}};

% keep only the combined (extra) events and throw out the original events?
exper.eventValuesExtra.onlyKeepExtras = 0;
exper.eventValuesExtra.equateExtrasSeparately = 0;

exper.subjects = {
  'CORE 07';
  'CORE 08';
  'CORE 09';
  'CORE 10';
  'CORE 11';
%  'CORE 12'; data missing
  'CORE 13';
  'CORE 14';
  'CORE 15';
  'CORE 16';
  'CORE 17';
  'CORE 18';  
    'CORE 19';
    'CORE 20';
    'CORE 21';
    'CORE 22';
    'CORE 23';
    'CORE 24';
%    'CORE 25'; data missing
    'CORE 26';
    'CORE 27';
    'CORE 28';
    'CORE 29';
  };

exper.sessions = {'ses1'};

%% set up file and directory handling parameters

% directory where the data to read is located
dirs.subDir = '';
dirs.dataDir = fullfile(exper.name,'eeg',sprintf('%dto%d',abs(exper.prepost(1)*1000),exper.prepost(2)*1000),dirs.subDir);

% Possible locations of the data files (dataroot)
dirs.serverDir = fullfile('/Volumes','curranlab','Data');
dirs.serverLocalDir = fullfile('/Volumes','RAID','curranlab','Data');
dirs.dreamDir = fullfile('/data','projects','oreillylab','nick','analysis');
dirs.localDir = fullfile(getenv('HOME'),'Documents','Documents','boulder','Masters');

% pick the right dirs.dataroot
if exist(dirs.localDir,'dir')
  dirs.dataroot = dirs.localDir;
  %runLocally = 1;
elseif exist(dirs.serverDir,'dir')
  dirs.dataroot = dirs.serverDir;
  %runLocally = 1;
elseif exist(dirs.serverLocalDir,'dir')
  dirs.dataroot = dirs.serverLocalDir;
  %runLocally = 1;
elseif exist(dirs.dreamDir,'dir')
  dirs.dataroot = dirs.dreamDir;
  %runLocally = 0;
else
  error('Data directory not found.');
end

% Use the FT chan locs file
files.elecfile = 'GSN-HydroCel-129.sfp';
files.locsFormat = 'besa_sfp';
ana.elec = ft_read_sens(files.elecfile,'fileformat',files.locsFormat);

% figure printing options - see mm_ft_setSaveDirs for other options
files.saveFigs = 1;
files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 150;

%% Convert the data to FieldTrip structs

ana.segFxn = 'nk_seg2ft';
ana.ftFxn = 'ft_freqanalysis';
%ana.artifact.type = 'none';
ana.artifact.type = 'nsAuto';

% any preprocessing?
cfg_pp = [];
% single precision to save space
cfg_pp.precision = 'single';

cfg_proc = [];
cfg_proc.output = 'pow';
cfg_proc.pad = 'maxperlen';
cfg_proc.keeptrials = 'yes';

% wavelet
cfg_proc.method = 'wavelet';
cfg_proc.width = 4;
%cfg_proc.toi = -0.8:0.04:3.0;
cfg_proc.toi = -0.5:0.04:2.0;
% evenly spaced frequencies, but not as many as foilim makes
freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
%cfg_proc.foi = 3:freqstep:50;
cfg_proc.foi = 3:freqstep:50;
%cfg_proc.foilim = [3 9];

% set the save directories
[dirs,files] = mm_ft_setSaveDirs(exper,ana,cfg_proc,dirs,files,'pow');

% ftype is a string used in naming the saved files (data_FTYPE_EVENT.mat)
ana.ftype = cfg_proc.output;

% create the raw and processed structs for each sub, ses, & event value
[exper] = create_ft_struct(ana,cfg_pp,exper,dirs,files);
process_ft_data(ana,cfg_proc,exper,dirs);

%% save the analysis details

% overwrite if it already exists
saveFile = fullfile(dirs.saveDirProc,'analysisDetails.mat');
%if ~exist(saveFile,'file')
fprintf('Saving %s...',saveFile);
save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
fprintf('\nDone.\n');
%else
%  error('Not saving! %s already exists.\n',saveFile);
%end

% %% let me know that it's done
% emailme = 1;
% if emailme
%   subject = sprintf('Done with%s',sprintf(repmat(' %s',1,length(exper.eventValues)),exper.eventValues{:}));
%   mail_message = {...
%     sprintf('Done with%s %s',sprintf(repmat(' %s',1,length(exper.eventValues)),exper.eventValues{:})),...
%     sprintf('%s',saveFile),...
%     };
%   send_gmail(subject,mail_message);
% end

%% load the analysis details

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


%adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Eimg_Red_Scene_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-500_1980_3_50/analysisDetails_postClass.mat.2012.10.16.11.16.46.backup.mat';

[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);

files.figFontName = 'Helvetica';
files.figPrintFormat = 'png';
files.figPrintRes = 150;

%files.figPrintFormat = 'tiff';
%files.figPrintRes = 1000;

%% set up channel groups

% pre-defined in this function
ana = mm_ft_elecGroups(ana);

%% list the event values to analyze; specific to each experiment

ana.eventValues = {exper.eventValues};

ana.eventValues{1} = cat(2,ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word_.*e$'))));

% ana.eventValues = {
% {'Word_Blue_Face_Switch',...
% 'Word_Blue_Scene_Switch',...
% 'Word_Green_Face_Switch',...
% 'Word_Green_Scene_Switch',...
% 'Word_Red_Face_Switch',...
% 'Word_Red_Scene_Switch'}
% };

%ana.eventValues = {exper.eventValues};

% %add newsucc to tail of Word conditions and remove other condition names
% tempvals = ana.eventValues{1};
% for iword = 1:length(tempvals)
%     if ~isempty(strfind(tempvals{iword},'Word'))
%         tempvals{iword} = [tempvals{iword} '_newsucc'];
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
[data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow',1);
%[data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,'pow',0);

%% decide who to kick out based on trial counts

% Subjects with bad behavior
exper.badBehSub = {};

% exclude subjects with low event counts
[exper] = mm_threshSubs(exper,ana,10);

%% baseline correct

cfg_fb = [];
cfg_fb.baseline = [-.3 -.1];
cfg_fb.baselinetype = 'absolute';
data_freq = nk_ft_baselinecorrect(data_freq,ana,exper,cfg_fb);

%% Test plots to make sure data look ok

cfg_ft = [];
cfg_ft.baseline = [-0.3 -0.1];
cfg_ft.baselinetype = 'absolute';
if strcmp(cfg_ft.baselinetype,'absolute')
  %cfg_ft.zlim = [-400 400];
  cfg_ft.zlim = [-2 2];
elseif strcmp(cfg_ft.baselinetype,'relative')
  cfg_ft.zlim = [0 2.0];
end
cfg_ft.zlim = [0 600];'maxabs';
cfg_ft.parameter = 'powspctrm';
cfg_ft.ylim = [3 20];
cfg_ft.xlim = [-1 2];
cfg_ft.showlabels = 'yes';
cfg_ft.colorbar = 'yes';
cfg_ft.interactive = 'yes';
cfg_ft.showoutline = 'yes';
cfg_ft.layout = ft_prepare_layout([],ana);
sub=1;
ses=1;
for i = 1
  figure
  ft_multiplotTFR(cfg_ft,data_freq.(ana.eventValues{1}{i}).sub(sub).ses(ses).data);
  title(ana.eventValues{1}{i});
end


%% run distributed classiffier training

cfg_cd = [];
cfg_cd.frequency = [3 50];
cfg_cd.mva = {dml.standardizer dml.enet('family','binomial','alpha',0.8)};
%cfg_cd.mva = {dml.standardizer dml.glmnet('family','binomial')};
cfg_cd.resample = true;
cfg_cd.name = 'enetalpha.8';
cfg_cd.nfolds = 5;

%cfg_cd.conds = {{'Timg_Scene'},{'Timg_Face'}};
%cfg_cd.conds = {{'Timg_Scene','Word_Green_Scene'},{'Timg_Face','Word_Green_Face'}};
cfg_cd.conds = {{'Word_Green_Scene'},{'Word_Green_Face'}};

%create testfolds cell array to target green condtions
%cfg_cd.testconds = [0 1; 0 1];

%processes multiple subjects in parallel
cfg_cd.subs = 1:length(exper.subjects);%9:11;
cfg_cd.latwidth = .2;
cfg_cd.latencies =  0:.04:1.3;

%cfg_cd.avgovertime = 'yes';

cfg_cd.method = 'crossvalidate_nk';
cfg_cd.persub = 1;
rundist = 1;
cfg_cd.savedata = 1;

if rundist
    cfg_cd.infile = adFile;
    cfg.baselinecorrect = 1;
        
    %save cfg_cd for use in wrapper function
    %create outfile str
    outdir = dirs.saveDirProc;
    outfile = fullfile(outdir,'CORE_nk_ft_pow_train_test_wrapper_cfg.mat');
    save(outfile,'cfg_cd');
    
    memlimit = '7g';
       
    %run wrapper script through distmsub
    cd(fullfile(dirs.dataroot,exper.name)); %must run from exp directory as it has a pathdef.m file in it
    status = system(['export MATLAB_SGE_FLAGS=''-l vf=' memlimit ''';/usr/local/bin/distmsub ' dirs.dataroot filesep exper.name filesep 'mat-mvm/core/core_nk_ft_pow_train_test_wrapper.m']);
    %status = system(['/usr/local/bin/distmsub ' dirs.dataroot filesep exper.name filesep 'mat-mvm/core/core_nk_ft_pow_train_test_wrapper.m']);

    if status == 0
        fprintf('Submitted job CORE_nk_ft_pow_train_test_wrapper.m...\n');
    else
        error('failed to submit CORE_nk_ft_pow_train_test_wrapper.m');
    end
else
    for isub = 1:length(cfg_cd.subs)
        cfg_cd.subNo = cfg_cd.subs(isub);
        cfg_cd.subStr = exper.subjects{isub};
        cfg_cd.latency = [cfg_cd.latencies(1) cfg_cd.latencies(1)+cfg_cd.latwidth];
        stat(isub) = nk_ft_pow_train(cfg_cd,data_freq,dirs,exper);
    end
end

%% load classifier data and find best performance

% create trldata struct in exper and save testresp strcut to file for each
% subject
% now in core_get_resp.m
% currently only written for first 6 subjects, changes must be made for
% later subjects
%
% all cfg fields below specified are required
%

cfg_gr =[];

cfg_gr.doplots = 1;
cfg_gr.saveplots = 1;
cfg_gr.savedata = 1;

cfg_gr.method = 'sumdiff';

cfg_gr.cname = 'enetalpha.8';
cfg_gr.frequency = [3 50];
cfg_gr.dobaseline = 1;
cfg_gr.trainconds = {{'Timg_Scene'},{'Timg_Face'}};
%cfg_gr.trainconds = {{'Word_Green_Scene'},{'Word_Green_Face'}};
cfg_gr.testconds = {...
    cfg_gr.trainconds...%train conds
    ,{{'Word_Green_Scene','Word_Blue_Scene','Word_Red_Face'}...%test conds label 0(scenes)
    ,{'Word_Green_Face','Word_Blue_Face','Word_Red_Scene'}}... %test conds label 1(faces)
    };
cfg_gr.twin = [0 1.35];%time window to look for best crossvalidation performance
cfg_gr.testlatency = [0 1.35];%time window to get test results for
cfg_gr.testlatwidth = 0.04;%width between testing time points
cfg_gr.dobaseline = 1;
cfg_gr.subjects = exper.subjects;

cfg_gr.runtest = 1;

[newexper,trainresult,testresult] = core_makeRespVec(cfg_gr,adFile);
exper = newexper;
exper.trainresult = trainresult;
exper.testresult = testresult;

% save the analysis details

% make backup file if AD file already exists
saveFile = fullfile(dirs.saveDirProc,'analysisDetails_postClass_sumdif.mat');
if exist(saveFile,'file');
    fprintf('Making backup file:\n%s',[saveFile '.' sprintf('%d.',floor(clock)) 'backup'])
    cmd = ['mv ' saveFile ' ' saveFile '.' sprintf('%d.',floor(clock)) 'backup'];
    status = system(cmd);
    if ~status == 0
        error('backup of original AD file failed');
    end
end
fprintf('Saving %s...',saveFile);
save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
fprintf('\nDone.\n');
adFile = saveFile;


%% do distributed training and testing together, and evalute perforamnce based on test
cfg_gr =[];

cfg_gr.doplots = 1;
cfg_gr.savedata = 1;

cfg_gr.cname = 'enetalpha.8';
cfg_gr.frequency = [3 50];
cfg_gr.dobaseline = 1;
cfg_gr.trainconds = {{'Timg_Scene'},{'Timg_Face'}};
cfg_gr.testconds = {...
    cfg_gr.trainconds...%train conds
    ,{{'Word_Green_Scene','Word_Blue_Scene','Word_Red_Face'}...%test conds label 0(scenes)
    ,{'Word_Green_Face','Word_Blue_Face','Word_Red_Scene'}}... %test conds label 1(faces)
    };

cfg_gr.latwidth = .2;
cfg_gr.trainlatencies = 0:.04:1.24-cfg_gr.latwidth;
cfg_gr.testlatency = [0 (1.25-cfg_gr.latwidth)];%time window to get test results for
cfg_gr.testlatwidth = 0.04;%width between testing time points
cfg_gr.dobaseline = 1;
cfg_gr.subs = exper.subjects;

cfg_gr.mva = {dml.standardizer dml.enet('family','binomial','alpha',0.8)};
cfg_gr.valconds = {[1 0 0] [1 0 0]};%defines which test conditions to use in evaluating performance

rundist = 1;

if rundist
    cfg_gr.infile = adFile;
    %save cfg_gr for use in wrapper function
    %create outfile str
    outdir = dirs.saveDirProc;
    outfile = fullfile(outdir,'CORE_nk_ft_pow_probetest_wrapper_cfg.mat');
    save(outfile,'cfg_gr');
    
    memlimit = '7g';
       
    %run wrapper script through distmsub
    cd(fullfile(dirs.dataroot,exper.name)); %must run from exp directory as it has a pathdef.m file in it
    status = system(['export MATLAB_SGE_FLAGS=''-l vf=' memlimit ''';/usr/local/bin/distmsub ' dirs.dataroot filesep exper.name filesep 'mat-mvm/core/core_nk_ft_pow_probetest_wrapper.m']);
    %status = system(['/usr/local/bin/distmsub ' dirs.dataroot filesep exper.name filesep 'mat-mvm/core/core_nk_ft_pow_train_test_wrapper.m']);

    if status == 0
        fprintf('Submitted job CORE_nk_ft_pow_probetest_wrapper.m...\n');
    else
        error('failed to submit CORE_nk_ft_pow_probetest_wrapper.m');
    end
else
    for isub = 1:length(cfg_gr.subs)
        cfg_gr.sub = cfg_gr.subs(isub);
        cfg_gr.trainlatency = [cfg_gr.trainlatencies(1) cfg_gr.trainlatencies(1)+cfg_gr.latwidth];
        [testresp,trainednet] = core_probeTest(cfg_gr,adFile);
    end
end

%% read probe test results and add resp vector to trldata in exper
cfg_pt = [];
cfg_pt.cname = 'enetalpha.8';
cfg_pt.doplots = 0;
cfg_pt.saveplots = 0;
cfg_pt.twin = [0 1.5];
cfg_pt.method = 'maxdiff';
[exper,maxperf,testresult,testresp] = core_readprobetest(cfg_pt,ana,dirs,exper,files);
exper.maxperf = maxperf;

% %save to new ad file
% saveFile = fullfile(dirs.saveDirProc,'analysisDetails_postTestClassAUC_maxdiff.mat');
% if exist(saveFile,'file');
%     fprintf('Making backup file:\n%s',[saveFile '.' sprintf('%d.',floor(clock)) 'backup'])
%     cmd = ['mv ' saveFile ' ' saveFile '.' sprintf('%d.',floor(clock)) 'backup'];
%     status = system(cmd);
%     if ~status == 0
%         error('backup of original AD file failed');
%     end
% end
% fprintf('Saving %s...',saveFile);
% save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
% fprintf('\nDone.\n');
% adFile = saveFile;

%% evaluate acc as a function of classifier defined 'reactivation'

cfg_ea = [];
cfg_ea.eventValues = ana.eventValues{1};
cfg_ea.vectype = 'memact';%pctincong,pctcong,cong,incong,congdiff
cfg_ea.normalize = 0;
cfg_ea.rmoutliers = 0;
cfg_ea.dofilt = 0;
cfg_ea.persub = 1;
%cfg_ea.mybeta = [-.04981 0.06686]';
cfg_ea.dosubplots = 0;
cfg_ea.plotconds = [0 0 0 1];
cfg_ea.kconds = [1 2];
cfg_ea.imgt = 2;
cfg_ea.nbins = 8;
cfg_ea.sthres = 5;
evts = ana.eventValues{1};
[newtrldata,acc,oldacc] = core_calcnewacc(exper.trldata,evts,dirs,exper,0);
condacc = mean(oldacc.all);
condacc(end+1) = mean(condacc(cfg_ea.kconds(1):cfg_ea.kconds(2)));
myresults = core_acceval_persubedit(cfg_ea,exper,oldacc);

%% write to file
perf = [];
mydata = [];
for isub = 1:length(myresults.k.V)
    if isfield(exper,'maxperf')
        perf(isub) = exper.maxperf(myresults.k.V(isub)).acc(1);
    else
        perf(isub) = mean(exper.testresult(myresults.k.V(isub)).acc(1));
    end
end
mydata=[myresults.k.X' myresults.k.Y' myresults.k.V' myresults.k.cond' myresults.k.imgt' myresults.k.stim' perf'];
cols = {'memact','acc','subn','condn','imgt','stimn','perf'};
[mydata,cols] = core_add_oacc(mydata,cols,dirs,exper);
fout = fopen('mydata_testvalmax_memact.dat','w');
fprintf(fout,'%s\t',cols{:});
fprintf(fout,'\n');
fprintf(fout,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',mydata');
fclose all;

%% make newcond vector based on memact
cfg_mac = [];
cfg_mac.savedata = 0;
cfg_mac.subjects = exper.subjects;
cfg_mac.congcrit = 0;
cfg_mac.eventValues = ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word_.*e$')));
exper = core_makeMemActConds(cfg_mac,adFile);

%% make newcond vector in trldata based on two parameter curve

cfg_tp = [];
cfg_tp.eventValues = ana.eventValues{1};
hcrits = .05:.1:.95;
lcrits = 0;%hcrits;
tvals = nan(length(lcrits),length(hcrits));
for ihcrits = 1:length(hcrits)
    for ilcrits = 1%:ihcrits%length(ilcrits)
        cfg_tp.lcrit = lcrits(ilcrits);
        cfg_tp.hcrit = hcrits(ihcrits);
        newtrldata = core_newcond_2p(cfg_tp,myresults.k,exper.trldata);
        [newtrldata,acc,oldacc] = core_calcnewacc(newtrldata,cfg_tp.eventValues,dirs,exper,0);
        temp = bsxfun(@minus,acc.all,acc.all(:,4));
        [h,p,ci,stats]= ttest(temp(:,2) - temp(:,3));
        tvals(ilcrits,ihcrits) = stats.tstat;
    end
end

%tvals = tvals.*(tvals>0);
imagesc(tvals);
set(gca,'xtick',1:length(hcrits));
set(gca,'ytick',1:length(lcrits));
set(gca,'xticklabel',hcrits);
set(gca,'yticklabel',lcrits);
ylabel('Lower bound');
xlabel('Upper bound');

maxt = max(max(tvals));
[x,y] = ind2sub(size(tvals),find(tvals==maxt));
cfg_tp.lcrit = lcrits(x);
cfg_tp.hcrit = hcrits(y);
newtrldata = core_newcond_2p(cfg_tp,myresults.k,exper.trldata);
[newtrldata,acc,oldacc,n] = core_calcnewacc(newtrldata,cfg_tp.eventValues,dirs,exper,1);
temp = bsxfun(@minus,acc.all,acc.all(:,4));
[h,p,ci,stats]= ttest(temp(:,2) - temp(:,3));

%% find congcrit value for best behavioral accuracies in TNT pattern
crits = -.75:.25:.75;
critvals = [];
tvals = [];
for icrit = 1:length(crits)
    cfg.congcrit = crits(icrit);
    cfg.eventValues = ana.eventValues{1};
    [exper, substruct] = core_getbehavmeas(exper,cfg);
    [newtrldata,acc,oldacc] = core_calcnewacc(exper.trldata,ana.eventValues{1}, dirs,exper,0);
    %CORE_nanplotacc(acc);
    %title(sprintf('congcrit %.02f',cfg.congcrit));
    temp = bsxfun(@minus,acc.all,acc.all(:,4));
    [h,p,ci,stats]= ttest(temp(:,2) - temp(:,3));
    tvals(icrit) = stats.tstat;
    %close all
    fnames = fieldnames(acc);
    for ilevel = 1:length(fnames)
        critvals.(fnames{ilevel})(icrit,:) = nanmean(acc.(fnames{ilevel})-oldacc.(fnames{ilevel}));
    end
end

% use this best value to create new conditions 
[m,imax] = max(tvals);
cfg.congcrit = crits(imax);
[exper, substruct] = core_getbehavmeas(exper,cfg);
[newtrldata,acc,oldacc,n] = core_calcnewacc(exper.trldata,ana.eventValues{1},dirs,exper,0);
temp = bsxfun(@minus,acc.all,acc.all(:,4));
[h,p,ci,stats]= ttest(temp(:,2) - temp(:,3));

CORE_nanplotacc(acc);
title('New ACC');
CORE_nanplotacc(oldacc);
title('Old ACC');

%% create new conditions based on classifier output filtered by cong crit
% value
cfg_msc = [];
cfg_msc.savedata = 1;
cfg_msc.subjects = exper.subjects;
cfg_msc.congcrit =crits(imax); %percent of congruent classifier output necessary to flip condition labels
cfg_msc.eventValues = ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word_.*e$')));
exper = core_makeCongCritConds(cfg_msc,adFile);

%% create new conditions based just on classifier output, and remove failed
% trials
cfg_msc = [];
cfg_msc.savedata = 1;
cfg_msc.subjects = exper.subjects;
cfg_msc.datatype = 'pow';
cfg_msc.eventValues = ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word.*e$')));
exper = core_makeSuccConds(cfg_msc,adFile);


%% create new conditions based just on classifier output, and switch failed
% trials to appropriate condition
cfg_msc = [];
cfg_msc.savedata = 1;
cfg_msc.subjects = exper.subjects;
cfg_msc.eventValues = ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word.*e$')));
exper = core_makeSwitchConds(cfg_msc,adFile);

%% combine face and scene conditions into a single condition
cfg_mcc = [];
cfg_mcc.savedata = 1;
cfg_mcc.subjects = exper.subjects;
cfg_mcc.eventValues = cat(2,exper.eventValues((~cellfun('isempty',regexp(exper.eventValues,'Word_.*_Succ$')))));
exper = core_makeCombConds(cfg_mcc,adFile);

%% split into Rem and Forg conditions
cfg_mmc = [];
cfg_mmc.savedata = 1;
cfg_mmc.subjects = exper.subjects;
cfg_mmc.eventValues = {'Word_Green_Comb_Succ','Word_Blue_Comb_Succ','Word_Red_Comb_Succ'};%cat(2,exper.eventValues((~cellfun('isempty',regexp(exper.eventValues,'Word_.*_Comb_Switch$')))));
exper = core_makeMemConds(cfg_mmc,adFile);

%% Combine conditions and split into Rem and Forg conditions
cfg_mmc = [];
cfg_mmc.savedata = 1;
cfg_mmc.subjects = exper.subjects;
cfg_mmc.eventValues = {'Word_Green_Comb_Succ','Word_Blue_Comb_Succ','Word_Red_Comb_Succ'};%cat(2,exper.eventValues((~cellfun('isempty',regexp(exper.eventValues,'Word_.*_Comb_Switch$')))));
exper = core_makeCombMemConds(cfg_mmc,adFile);

%% save the analysis details
fprintf('\n');
% make backup file if AD file already exists
%saveFile = fullfile(dirs.saveDirProc,'analysisDetails_postClass_verify.mat');
saveFile = adFile;
if exist(saveFile,'file');
    fprintf('Making backup file:\n%s',[saveFile '.' sprintf('%d.',floor(clock)) 'backup'])
    cmd = ['mv ' saveFile ' ' saveFile '.' sprintf('%d.',floor(clock)) 'backup'];
    status = system(cmd);
    if ~status == 0
        error('backup of original AD file failed');
    end
end
fprintf('Saving %s...',saveFile);
save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
fprintf('\nDone.\n');
adFile = saveFile;
