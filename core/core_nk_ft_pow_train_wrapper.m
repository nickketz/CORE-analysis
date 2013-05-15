function core_nk_ft_pow_train_wrapper(whichStages)
% tnt_ftprocess_tfr_pow_wrapper(whichStages)
%
% To run on dream, at the command line type: distmsub core_nk_ft_pow_train_wrapper.m
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
%  saved mat file with classifier statistics
%

% check/handle arguments
error(nargchk(0,1,nargin))
STAGES = 1;
if nargin == 1
  STAGES = whichStages;
end

runLocally = 0;

% % load analysisDetails instead of using specifications below
% if runLocally == 0
%   adFile = '/data/projects/curranlab/TNT_matt/eeg/-1000_1700/ft_data/B_NT_TH_eq1/conn_scd_mtmconvol_hanning_fourier_-500_980_3_9/analysisDetails.mat';
%   [exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,true);
% elseif runLocally == 1
%   adFile = '/Volumes/curranlab/TNT/TNT_matt/eeg/-1000_1700/ft_data/B_NT_TH_eq1/conn_scd_mtmconvol_hanning_fourier_-500_980_3_9/analysisDetails.mat';
%   [exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,true);
% end

adFile = '/data/projects/oreillylab/nick/CORE_EEG/data/eeg/1000to1700/ft_data/EIMG_Red_Scene_Eimg_Blue_Face_Eimg_Blue_Scene_Eimg_Green_Face_Eimg_Green_Scene_Eimg_Red_Face_Timg_Face_Timg_Scene_Word_Blue_Face_Word_Blue_Scene_Word_Green_Face_Word_Green_Scene_Word_Red_Face_Word_Red_Scene_eq0_art_nsAuto/pow_wavelet_w4_pow_-1000_1000_3_50/analysisDetails.mat';
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,true);

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
%thisRun = [exper.name,'_overview_',datestr(now,7) datestr(now,3) datestr(now,10)];
diary(fullfile(dirs.saveDirProc,[thisRun '.log']));
tStart = tic;
fprintf('START TIME: %s\n',datestr(now,13));
for i = STAGES
  tS = tic;
  fprintf('STAGE%d START TIME: %s\n',i, datestr(now,13));
  
  % execute the processing stage
  stageFun{i}(ana,exper,dirs,adFile,runLocally,timeOut{i});
  
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

function stage1(ana,exper,dirs,adFile,runLocally,timeOut)
% stage1: process the input files with FieldTrip based on the analysis
% parameters

%% Process the data
if runLocally == 0
    %% Dream: create one task for each timewindow
    
    % start a new job
    job = newJob(dirs);
    
    cfg_cd = [];
    cfg_cd.frequency = [3 50];
    cfg_cd.mva = {dml.standardizer dml.enet('family','binomial','alpha',0.2) dml.naive};
    cfg_cd.name = 'enet-naive';
    %cfg_cd.mva = {dml.standardizer dml.naive};
    cfg_cd.nfolds = 5;
    cfg_cd.conds = {'Timg_Scene','Timg_Face'};
    cfg_cd.subNo = 1;
    
        
    cfg_cd.infile = adFile;
    cfg.baselinecorrect = 1;
    cfg_cd.savedata = 1;
    
    for ilat = -.4:.04:.8
        cfg_cd.latency = [ilat ilat+.2];
        inArg = {cfg_cd};
        createTask(job,@nk_ft_pow_train,0,inArg);
    end
    
    
    runJob(job, timeOut, fullfile(dirs.saveDirProc,[exper.name,'_stage1_',datestr(now,'ddmmmyyyy-HHMMSS'),'.log']));
    
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
  
  cfg_cd = [];
  cfg_cd.frequency = [3 50];
  cfg_cd.mva = {dml.standardizer dml.enet('family','binomial','alpha',0.2)};
  cfg_cd.name = 'enet';
  %cfg_cd.mva = {dml.standardizer dml.naive};
  cfg_cd.nfolds = 2;
  cfg_cd.conds = {'Timg_Scene','Timg_Face'};
  cfg_cd.subNo = 1;
  
  
  cfg_cd.infile = adFile;
  cfg_cd.pathdef = fullfile(dirs.dataroot,exper.name,'pathdef');
  cfg.baselinecorrect = 1;
  cfg_cd.savedata = 1;
  
  for ilat = .2:.04:.8
      cfg_cd.latency = [ilat ilat+.2];
      inArg = {cfg_cd};
      nk_ft_pow_train(cfg_cd)
  end
  
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

