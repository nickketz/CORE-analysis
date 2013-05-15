% Make plots and do analyses for time-frequency EEG data

% See Maris & Oostenveld (2007) for a info on nonparametric statistics

% initialize the analysis structs
exper = struct;
files = struct;
dirs = struct;
ana = struct;

%% Experiment-specific setup

exper.name = 'CORE';

exper.sampleRate = 250;

% pre- and post-stimulus times to read, in seconds (pre is negative)
exper.prepost = [-1.0 1.7];

% equate the number of trials across event values?
exper.equateTrials = 1;

% type of NS file for FieldTrip to read; raw or sbin must be put in
% dirs.dataroot/ns_raw; egis must be put in dirs.dataroot/ns_egis
exper.eegFileExt = 'egis';
%exper.eegFileExt = 'raw';

% types of events to find in the NS file; these must be the same as the
% events in the NS files
exper.eventValues = sort({'GrR1of2','GrR2of2','GrF1of2','GrF2of2',...
                          'BlR1of2','BlR2of2','BlF1of2','BlF2of2',...
                          'ReR1of2','ReR2of2','ReF1of2','ReF2of2'});
                      
%exper.eventValues = sort({'NT1of2Rec','T1of2Rec'});

% combine some events into higher-level categories
exper.eventValuesExtra.toCombine = {...
    
  };
exper.eventValuesExtra.newValue = {...
%   {'B'},...
  {'NT'},...
  {'TH'}...
%   {'NT1'},{'NT2'}...
%   {'TH1'},{'TH2'}...
%   {'NTF'},{'NTR'}...
%   {'THF'},{'THR'}...
  };

% keep only the combined (extra) events and throw out the original events?
exper.eventValuesExtra.onlyKeepExtras = 1;

exper.subjects = {
  'TNT 06';
  'TNT 07';
  'TNT 08';
  'TNT 09';
  'TNT 11';
  'TNT 13';
  'TNT 14';
  'TNT 15';
  'TNT 17';
  'TNT 19';
  'TNT 20';
  'TNT 21';
  'TNT 22';
  'TNT 23';
  'TNT 25';
  'TNT 26';
  'TNT 27';
  'TNT 28';
  'TNT 30';
  'TNT 32';
  'TNT 33';
  'TNT 35';
  'TNT 39';
  'TNT 41';
  'TNT 42';
  'TNT 44';
  'TNT 45';
  'TNT 46';
  'TNT 47';
  'TNT 48';
  'TNT 49';
  'TNT 50';
  'TNT 51';
  'TNT 52';
  'TNT 53';
  'TNT 54';
  };

% The sessions that each subject ran; the strings in this cell are the
% directories in dirs.dataDir (set below) containing the ns_egis/ns_raw
% directory and, if applicable, the ns_bci directory. They are not
% necessarily the session directory names where the FieldTrip data is saved
% for each subject because of the option to combine sessions. See 'help
% create_ft_struct' for more information.
exper.sessions = {'ses1'};

%% set up file and directory handling parameters

% directory where the data to read is located
dirs.dataDir = fullfile(exper.name,'TNT_matt','eeg',sprintf('%d_%d',exper.prepost(1)*1000,exper.prepost(2)*1000));

% Possible locations of the data files (dataroot)
dirs.serverDir = fullfile('/Volumes','curranlab','Data');
dirs.serverLocalDir = fullfile('/Volumes','RAID','curranlab','Data');
dirs.dreamDir = fullfile('/data','projects','curranlab');
dirs.localDir = fullfile(getenv('HOME'),'data');

% pick the right dirs.dataroot
if exist(dirs.serverDir,'dir')
  dirs.dataroot = dirs.serverDir;
  %runLocally = 1;
elseif exist(dirs.serverLocalDir,'dir')
  dirs.dataroot = dirs.serverLocalDir;
  %runLocally = 1;
elseif exist(dirs.dreamDir,'dir')
  dirs.dataroot = dirs.dreamDir;
  %runLocally = 0;
elseif exist(dirs.localDir,'dir')
  dirs.dataroot = dirs.localDir;
  %runLocally = 1;
else
  error('Data directory not found.');
end

% Use the FT chan locs file
files.elecfile = 'GSN-HydroCel-129.sfp';
files.locsFormat = 'besa_sfp';
ana.elec = ft_read_sens(files.elecfile,'fileformat',files.locsFormat);

% figure printing options - see mm_ft_setSaveDirs for other options
files.saveFigs = 1;
files.figPrintFormat = 'png';
%files.figPrintFormat = 'epsc2';

%% Convert the data to FieldTrip structs

ana.segFxn = 'seg2ft';
ana.ftFxn = 'ft_freqanalysis';
ana.artifact.type = 'nsAuto';

% any preprocessing?
cfg_pp = [];
% single precision to save space
cfg_pp.precision = 'single';

cfg_proc = [];
cfg_proc.output = 'pow';
cfg_proc.pad = 'maxperlen';
cfg_proc.keeptrials = 'no';
cfg_proc.keeptapers = 'no';

% % MTM FFT
% cfg_proc.method = 'mtmfft';
% cfg_proc.taper = 'dpss';
% %cfg_proc.foilim = [3 50];
% freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
% %cfg_proc.foi = 3:freqstep:50;
% cfg_proc.foi = 3:freqstep:9;
% cfg_proc.tapsmofrq = 5;
% cfg_proc.toi = -0:0.04:1.0;

% multi-taper method
cfg_proc.method = 'mtmconvol';
cfg_proc.taper = 'hanning';
%cfg_proc.taper = 'dpss';
%cfg_proc.toi = -0.8:0.04:3.0;
cfg_proc.toi = -0.5:0.04:1.0;
freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
%cfg_proc.foi = 3:freqstep:50;
cfg_proc.foi = 3:freqstep:9;
%cfg_proc.foi = 3:1:9;
%cfg_proc.foi = 2:2:30;
cfg_proc.t_ftimwin = 4./cfg_proc.foi;
% tapsmofrq is not used for hanning taper; it is used for dpss
%cfg_proc.tapsmofrq = 0.4*cfg_proc.foi;

% % wavelet
% cfg_proc.method = 'wavelet';
% cfg_proc.width = 5;
% %cfg_proc.toi = -0.8:0.04:3.0;
% cfg_proc.toi = -0.3:0.04:1.0;
% % evenly spaced frequencies, but not as many as foilim makes
% freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
% %cfg_proc.foi = 3:freqstep:50;
% cfg_proc.foi = 3:freqstep:9;
% %cfg_proc.foilim = [3 9];

% set the save directories; final argument is prefix of save directory
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
fprintf('Done.\n');
%else
%  error('Not saving! %s already exists.\n',saveFile);
%end
