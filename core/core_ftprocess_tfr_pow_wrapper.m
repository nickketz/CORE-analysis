function core_ftprocess_tfr_pow_wrapper(whichStages)
% tnt_ftprocess_tfr_pow_wrapper(whichStages)
%
% To run on dream, at the command line type: distmsub core_ftprocess_tfr_pow_wrapper.m
%
% To run on a local computer, type the command in MATLAB
%
% There is only one stage:
%  stage1 = call wrapper that calls create_ft_struct (which calls seg2ft,
%  which calls ft_freqanalysis) and saves one file per subject
%
% Input:
%  whichStages: the stage number(s) to run (default = 1)
%
% Output:
%  time-frequency data

% check/handle arguments
error(nargchk(0,1,nargin))
STAGES = 1;
if nargin == 1
  STAGES = whichStages;
end

% initialize the analysis structs
exper = struct;
files = struct;
dirs = struct;
ana = struct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODIFY THIS STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    %CORE 1 to 18 have 7ms offset
  'CORE 07';
  'CORE 08';
  'CORE 09';
  'CORE 10';
  'CORE 11';
  %'CORE 12'; data missing
  'CORE 13';
  'CORE 14';
  'CORE 15';
  'CORE 16';
  'CORE 17';
  'CORE 18';  
  % after CORE 18 different offset in segmentation (17ms)
    'CORE 19';
    'CORE 20';
    'CORE 21';
    'CORE 22';
    'CORE 23';
    'CORE 24';
    %'CORE 25'; data missing
    'CORE 26';
    'CORE 27';
    'CORE 28';
    'CORE 29';
    'CORE 30';
    'CORE 31';
    'CORE 32';
    'CORE 33';
    'CORE 34';
    'CORE 35';
    %'CORE 36'; data missing
    'CORE 37';
    'CORE 38';
    %'CORE 39'; data missing
    'CORE 40';
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
runLocally = 0;

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
%[exper] = create_ft_struct(ana,cfg_pp,exper,dirs,files);
%process_ft_data(ana,cfg_proc,exper,dirs);


%% set up for running stages and specifics for Dream

% name(s) of the functions for different stages of processing
stageFun = {@stage1};
timeOut  = {2}; % in HOURS

if runLocally == 0
  % need to export DISPLAY to an offscreen buffer for MATLAB DCS graphics
  sched = findResource();
  if strcmp(sched.Type, 'generic')
    setenv('DISPLAY', 'dream:99');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%capture diary and time statistics
thisRun = [exper.name,'_overview_',datestr(now,'ddmmmyyyy-HHMMSS')];
diary(fullfile(dirs.saveDirProc,[thisRun '.log']));
tStart = tic;
fprintf('START TIME: %s\n',datestr(now,13));
for i = STAGES
  tS = tic;
  fprintf('STAGE%d START TIME: %s\n',i, datestr(now,13));
  
  % execute the processing stage
  stageFun{i}(ana,cfg_pp,cfg_proc,exper,dirs,files,runLocally,timeOut{i});
  
  fprintf('STAGE%d END TIME: %s\n',i, datestr(now,13));
  fprintf('%.3f -- elapsed time STAGE%d (seconds)\n', toc(tS), i);
end
time = toc(tStart);
fprintf('%.3f -- elapsed time OVERALL (seconds)\n', time);
fprintf('END TIME: %s\n',datestr(now,13));
diary off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage1(ana,cfg_pp,cfg_proc,exper,dirs,files,runLocally,timeOut)
% stage1: process the input files with FieldTrip based on the analysis
% parameters

%% Process the data
if runLocally == 0
  %% Dream: create one task for each subject (i.e., submit one to each node)
  
  % start a new job
  job = newJob(dirs);
  
  % save the original subjects array so we can set exper to have single
  % subjects, one for each task created
  allSubjects = exper.subjects;
  
  for i = 1:length(allSubjects)
    fprintf('Processing %s...\n',allSubjects{i});
    
    % Dream: create one task for each subject
    exper.subjects = allSubjects(i);
    
    inArg = {ana,cfg_pp,cfg_proc,exper,dirs,files};
    
    % save the exper struct (output 1) so we can use it later
    createTask(job,@nk_create_ft_struct,1,inArg);
  end
  
  runJob(job,timeOut,fullfile(dirs.saveDirProc,[exper.name,'_stage1_',datestr(now,'ddmmmyyyy-HHMMSS'),'.log']));
  
  % get the trial counts together across subjects, sessions, and events
  [exper] = mm_ft_concatTrialCounts_cluster(job,exper,allSubjects);

  % save the analysis details; overwrite if it already exists
  saveFile = fullfile(dirs.saveDirProc,sprintf('analysisDetails.mat'));
  %if ~exist(saveFile,'file')
  fprintf('Saving %s...',saveFile);
  save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
  fprintf('Done.\n');
  %else
  %  error('Not saving! %s already exists.\n',saveFile);
  %end
  
  % final step: destroy the job because this doesn't happen in runJob
  destroy(job);
  
else
  %% run the function locally
  
  % create a log of the command window output
  thisRun = [exper.name,'_stage1_',datestr(now,'ddmmmyyyy-HHMMSS')];
  % turn the diary on
  diary(fullfile(dirs.saveDirProc,[thisRun,'.log']));
  
  % use the peer toolbox
  %ana.usePeer = 1;
  ana.usePeer = 0;
  
  % Local: run all the subjects
  [exper] = create_ft_struct(ana,cfg_pp,cfg_proc,exper,dirs,files);
  
  % save the analysis details; overwrite if it already exists
  saveFile = fullfile(dirs.saveDirProc,sprintf('analysisDetails.mat'));
  %if ~exist(saveFile,'file')
  fprintf('Saving %s...',saveFile);
  save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
  fprintf('Done.\n');
  %else
  %  error('Not saving! %s already exists.\n',saveFile);
  %end
  
  % turn the diary off
  diary off
end

function job = newJob(dirs)
% newJob Creates a new PCT job and sets job's dependencies
%
%   dirs -- data structure with necessary fields like data locations

% Set up scheduler, job
sched = findResource();
job = createJob(sched);
% define the directories to add to worker sessions' matlab path
homeDir = getenv('HOME');
myMatlabDir = fullfile(homeDir,'Documents','MATLAB');
p = path();
set(job, 'PathDependencies', {homeDir, myMatlabDir, pwd(), p, dirs.dataroot});

function runJob( job, timeOut, logFile )
% runJob Submits and waits on job to finish or timeout
%  runJob will submit the supplied job to the scheduler and will
% wait for the job to finish or until the timeout has been reached. 
% If the job finishes, then the command window outputs of all tasks
% are appended to the log file and the job is destroyed.
%   If the timeout is reached, an error is reported but the job is not
% destroyed.
%
%   job -- the job object to submit
%   timeOut -- the timeout value in hours
%   logFile -- full file name of the log file to append output to
%
% Example:
%       runJob( job, 5, 'thisrun.log');

% check/handle arguments
error(nargchk(1,3,nargin))
TIMEOUT=3600*5; % default to 5 hours 
if nargin > 1
  TIMEOUT=timeOut*3600;
end
LOGFILE=[job.Name '.log'];
if nargin > 2
  LOGFILE = logFile;
end

% Capture command window output from all tasks
alltasks = get(job, 'Tasks');
set(alltasks, 'CaptureCommandWindowOutput', true);

% Submit Job/Tasks and wait for completion (or timeout)
submit(job)
finished = waitForState(job, 'finished', TIMEOUT);
if finished
  errors = logOutput(alltasks, LOGFILE);
  if errors
    error([mfilename ':logOutput'],'%s had %d errors',job.Name, errors)
  %elseif ~errors
  %  destroy(job);
  end
else
  error([mfilename ':JobTimeout'],'%s: Timed out waiting for job...NAME: %s',...
    datestr(now, 13), job.Name, job.ID, job.StartTime)
end

function numErrors=logOutput( tasks, logFile )
% logOutput - concatenates tasks' output into a logfile
%   tasks -- the tasks to capture output from 
%   logFile -- the file to log the output to
%   numErrors -- number of tasks which failed

% check for argument(s)
error(nargchk(2,2,nargin))

numErrors=0;
try
  fid=fopen(logFile, 'a+');
  for i=1:length(tasks)
    fprintf(fid,'\n***** START TASK %d *****\n',i);
    fprintf(fid,'%s\n', tasks(i).CommandWindowOutput);
    if ~isempty(tasks(i).Error.stack)
      numErrors = numErrors +1;
      % write to log file
      fprintf( fid, 'ERROR: %s\n', tasks(i).Error.message );
      fprintf( fid, '%s\n', tasks(i).Error.getReport );
      % write to standard error
      fprintf( 2, 'ERROR: %s\n', tasks(i).Error.message );
      fprintf( 2, '%s\n', tasks(i).Error.getReport );
    end
    fprintf(fid,'\n***** END TASK %d *****\n',i);
  end
  fclose(fid);
catch ME
  disp(ME)
  warning([mfilename ':FailOpenLogFile'],...
    'Unable to write log file with task output...');
end