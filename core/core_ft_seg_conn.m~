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
exper.eventValues = sort({...
    'Word_Green_Scene','Word_Green_Face',...
    'Word_Blue_Scene','Word_Blue_Face',...
    'Word_Red_Scene','Word_Red_Face'...
    });
    

% combine some events into higher-level categories
%exper.eventValuesExtra.toCombine = {{'CHSC','CHSI'},{'SHSC','SHSI'}};

% keep only the combined (extra) events and throw out the original events?
exper.eventValuesExtra.onlyKeepExtras = 0;
exper.eventValuesExtra.equateExtrasSeparately = 0;

exper.subjects = {
  'CORE 07'};
%   'CORE 08';
%   'CORE 09';
%   'CORE 10';
%   'CORE 11';
% %  'CORE 12'; data missing
%   'CORE 13';
%   'CORE 14';
%   'CORE 15';
%   'CORE 16';
%   'CORE 17';
%   'CORE 18';  
%     'CORE 19';
%     'CORE 20';
%     'CORE 21';
%     'CORE 22';
%     'CORE 23';
%     'CORE 24';
% %    'CORE 25'; data missing
%     'CORE 26';
%     'CORE 27';
%     'CORE 28';
%     'CORE 29';
%   };

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
files.figPrintRes = 300;

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
cfg_proc.pad = 'maxperlen';

cfg_proc.output = 'fourier';
cfg_proc.channelcmb = {'all','all'};
% need to keep trials for fourier; not for powandcsd
cfg_proc.keeptrials = 'yes';
cfg_proc.keeptapers = 'yes';

% wavelet
cfg_proc.method = 'wavelet';
cfg_proc.width = 4;
%cfg_proc.toi = -0.8:0.04:3.0;
cfg_proc.toi = -0.5:0.04:2.0;
% evenly spaced frequencies, but not as many as foilim makes
freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
%cfg_proc.foi = 3:freqstep:50;
cfg_proc.foi = 3:freqstep:50;


% set the save directories
[dirs,files] = mm_ft_setSaveDirs(exper,ana,cfg_proc,dirs,files,'conn');

% set ftype to name the output file
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
fprintf('Done.\n');
%else
%  error('Not saving! %s already exists.\n',saveFile);
%end

%% load the analysis details

adFile = '/data/projects/oreillylab/nick/analysis/CORE_EEG/eeg/1000to2000/ft_data/Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/conn_wavelet_w4_fourier_-500_1980_3_50/analysisDetails.mat';

[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);

files.figFontName = 'Helvetica';
files.figPrintFormat = 'png';
files.figPrintRes = 300;
files.saveFigs = 1;


%% create new conditions based just on classifier output, and remove failed
% trials
cfg_msc = [];
cfg_msc.savedata = 1;
cfg_msc.subjects = exper.subjects;
cfg_msc.datatype = 'fourier';
cfg_msc.param = 'fourierspctrm';
cfg_msc.eventValues = ana.eventValues{1}(~cellfun('isempty',regexp(ana.eventValues{1},'Word.*e$')));
exper = core_makeSuccConds_edit(cfg_msc,adFile);


%% combine face and scene conditions into a single condition
cfg_mcc = [];
cfg_mcc.savedata = 1;
cfg_mcc.subjects = exper.subjects;
cfg_mcc.datatype = 'fourier';
cfg_mcc.param = 'fourierspctrm';
cfg_mcc.eventValues = cat(2,exper.eventValues((~cellfun('isempty',regexp(exper.eventValues,'Word_.*_Succ$')))));
exper = core_makeCombConds(cfg_mcc,adFile);

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

