function [ft_raw,badChanAllSes] = seg2ft(dataroot,subject,session,eventValue,elecfile,ana,exper)
%SEG2FT: take segmented EEG data and put it in FieldTrip format
%
% [ft_raw,badChan] = seg2ft(dataroot,subject,session,eventValue,elecfile,ana,exper)
%
% Output:
%   ft_raw  = struct with one field for each event value
%   badChan = bad channel information
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP:
%
% Export Net Station data as either EGIS (129 channels, where the final
% channel [Cz] is the reference; extension: 'egis') or NS Simple Binary
% (extension: 'raw' or 'sbin') calibrated, including the reference channel.
% These options are in the File Export tool. create_ft_struct, the function
% that calls seg2ft, expects EGIS files to be stored in a 'ns_egis'
% directory at the level of dirs.dataDir. If using raw files, they should
% be in 'ns_raw' instead.
%
% This function can deal with event values that have zero events. It is
% probably better to check on your event count and exclude those subjects
% with zero events for any of the event values you're trying to keep before
% trying to run this script. Nonetheless, it will insert an empty event
% entry for an empty eventValue, and the subjects will be excluded when
% using mm_threshSubs.m.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARTIFACT INFORMATION:
%
% ana.artifact.type can be 'none', 'nsAuto', 'zeroVar', 'preRejManual',
% 'ftManual', 'ftICA', 'badChanManual', 'badChanEP', and/or 'rmBadChan'.
% Default is {'none'}.
%
% It can be one of those strings or a cell array of multiple strings (e.g.,
% {'nsAuto','preRejManual'} to do both Net Station artifact rejection and
% FieldTrip manual ("visual") rejection). 'ftICA' also includes manual
% rejection after manually assessing components. Though it is not prohibited,
% 'nsAuto' and 'zeroVar' should not be used together because there is
% probably no good reason to find bad trials with both EP Toolkit and NS.
%
% 'nsAuto', 'zeroVar', and 'preRejManual' are processed first, then 'ftManual',
% then 'ftICA'. Subquent processing will not include earlier rejected artifacts.
% Note: any FT artifact processing requires manual intervention (as does 'preRejManual'),
% while 'nsAuto' and 'zeroVar' artifact processing does not. 'preRejManual' is for
% inspecting the artifacts that have been previously identified by other
% software (NS, EP Toolkit, etc.). After manual inspection, both 'preRejManual'
% and 'ftManual' give the option to repair individual channels (for all
% trials) using FT_CHANNELREPAIR, so be sure to keep track of any channels
% that you want to repair (i.e., instead of rejecting them as artifacts).
%
% If using NS artifacts ('nsAuto'), this function expects to find a Net Station
% segment info file with a .bci extension; this contains artifact information.
% It is exported from Net Station using the File Export tool. To set up the tool,
% export format is metadata and check the segment information option. Run
% the tool on the file that was exported to egis/raw (i.e., the baseline
% correction file or the average rereference file). The bci files should be
% stored in a 'ns_bci' directory in fullfile(dirs.dataroot,dirs.dataDir).
%
% Rejecting trials with zero variance ('zeroVar') should be used when using
% bad trial detection done by EP Toolkit because it flattens all channels
% of any bad trials.
%
% If 'ftManual', a visualization of all channels for each event will appear,
% where each trial is shown one-by-one.
%
% If 'ftICA', ICA will run on all trials across all event values.
% Individual components can be rejected after this.  Finally, a
% visualization of all channels for each event will appear, where each
% trial is shown one-by-one.
%
% 'badChanManual' requires a tab-delimited file titled
% [exper.name,'_badChan.txt'] to reside in
% fullfile(dirs.dataroot,dirs.dataDir). The three tab columns are subject
% name (e.g., EXPER001), session name (e.g., session_0), and bad channel
% numbers listed as integers in brackets (e.g., [56 93]). Using this option
% does not modify the data.
%
% 'badChanEP' requires the Artifact_Correction_Log output from EP Toolkit
% artifact processing, and must reside in a directory labeled with the
% session name (from exper.sessions) which is in a directory called
% 'ep_art' in fullfile(dirs.dataroot,dirs.dataDir). This will only look for
% channels listed as being globally bad. Using this option does not modify
% the data.
%
% For the badChan methods, 'rmBadChan' gives the option to delete those
% channels from the data using ft_rejectvisual. Using this option will
% return the data without the bad channels.
% NB: If you edit mm_ft_artifact you can turn those channels into NaNs, or
% do that later on your own.
%
% !!!EXTREMELY IMPORTANT!!! (Disclaimer: I'm not 100% about this)
% Do not reject ICA components from data that has already had
% ICA components rejected. Also, be very wary about rejecting ICA
% components if you want to do phase analyses; I think ICA screws up phase
% information, but I need to gather more information on this. See this PDF
% for more details:
% http://www.appliedneuroscience.com/Tutorial%20on%20ICA%20Phase%20Adulteration.pdf
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EEGLAB DATA
%
% If using eeglab data, no artifact detection is done and no bci file is
% expected to exist. Also, the directory structure is different and can be
% gleaned by examining the code here, but right now it is only set up to
% process Erika Nyhus's KAHN2 data.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See also: CREATE_FT_STRUCT, MM_FT_ARTIFACT, PROCESS_FT_DATA,
% FT_CHANNELREPAIR, FT_REJECTVISUAL
%

%% set the artifact processing parameters

if ischar(ana.artifact.type)
  ana.artifact.type = {ana.artifact.type};
end

artifactOpts = {'none','nsAuto','zeroVar','badChanManual','badChanEP','rmBadChan','preRejManual','ftAuto','ftManual','ftICA'};

if any(~ismember(ana.artifact.type,artifactOpts))
  error('an artifact option was not set correctly (it was set to ''%s'')',cell2mat(ana.artifact.type(~ismember(ana.artifact.type,artifactOpts))))
end

% set artifact defaults
if any(ismember(ana.artifact.type,artifactOpts)) && ~ismember('none',ana.artifact.type)
  rejArt = true;
else
  rejArt = false;
end

%% set up some processing parameters

% make sure eventValue is set up correctly
if ~iscell(eventValue)
  eventValue = {eventValue};
end
% if length(eventValue) > 1
%   error('Expecting only one eventValue.');
% end

if ~iscell(session)
  session = {session};
end
if length(session) > 1
  append_data = struct;
end

if strcmpi(exper.eegFileExt,'raw') || strcmpi(exper.eegFileExt,'sbin')
  ftype = 'egi_sbin';
  nsDir = 'ns_raw';
elseif strcmpi(exper.eegFileExt,'egis')
  ftype = 'egi_egis';
  nsDir = 'ns_egis';
elseif strcmpi(exper.eegFileExt,'set')
  ftype = 'eeglab_set';
  nsDir = subject;
else
  error('ftype not set because extension was not properly set.');
end

% make sure the chan locs file exists
%
% if this is an EGI electrode location file included with FieldTrip, the 3
% Fid (fiduciary) points are included, meaning there are 3 non-electrodes
% in elec.label
if ~exist(elecfile,'file')
  error('Cannot find channel locs file at %s',elecfile);
else
  [cpath,cname,cext] = fileparts(elecfile);
  if strcmpi(cext,'.sfp')
    locsFormat = 'besa_sfp';
  else
    locsFormat = [];
  end
  elec = ft_read_sens(elecfile,'fileformat',locsFormat);
end
% get rid of the fiduciary channels
elec.label = ft_channelselection({'all','-Fid*'},elec.label);
nChan_elecfile = size(elec.label,1);

badChanAllSes = [];

%% for each session, read in the EEG file

for ses = 1:length(session)
  sesName = session{ses};
  
  % set sesStr to make sure it starts with a character, not a #, etc.
  sesStr = sprintf('ses_%s',sesName);
  
  if strcmpi(exper.eegFileExt,'sbin') || strcmpi(exper.eegFileExt,'raw') || strcmpi(exper.eegFileExt,'egis')
    % make sure the EEG file exists
    nsfile = dir(fullfile(dataroot,sesName,nsDir,[subject,'*.',exper.eegFileExt]));
    if isempty(nsfile)
      error('Cannot find %s*.%s file in %s',subject,exper.eegFileExt,fullfile(dataroot,sesName,nsDir));
    elseif length(nsfile) > 1
      error('More than one %s*.%s file found in %s',subject,exper.eegFileExt,fullfile(dataroot,sesName,nsDir));
    elseif length(nsfile) == 1
      infile_ns = fullfile(dataroot,sesName,nsDir,nsfile.name);
    end
    
  elseif strcmpi(exper.eegFileExt,'set')
    % this is really just set up to analyze Erika Nyhus's KAHN2 data
    
    %isclean = 1;
    clean_str = 'clean';
    
    %if isclean
    %  clean_str = 'clean';
    %else
    %  clean_str = '';
    %end
    
    nsfile = dir(fullfile(dataroot,nsDir,[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),exper.eegFileExt]));
    if isempty(nsfile)
      error('Cannot find %s file in %s',[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),exper.eegFileExt],fullfile(dataroot,nsDir));
    elseif length(nsfile) > 1
      error('More than one %s file found in %s',[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),exper.eegFileExt],fullfile(dataroot,nsDir));
    elseif length(nsfile) == 1
      infile_ns = fullfile(dataroot,nsDir,nsfile.name);
    end
  end
  
  % % debug
  % hdr = ft_read_header(infile_ns,'dataformat',ftype,'headerformat',ftype);
  % data = ft_read_data(infile_ns,'dataformat',ftype,'headerformat',ftype);
  % event = ft_read_event(infile_ns,'eventformat',ftype,'dataformat',ftype,'headerformat',ftype);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Initial parameters for reading the data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  cfg = [];
  cfg.dataset = infile_ns;
  cfg.headerfile = infile_ns;
  if ~isempty(ftype)
    cfg.dataformat = ftype;
    cfg.headerformat = ftype;
  end
  cfg.continuous = 'no';
  
  % % debug
  % data = ft_preprocessing(cfg);
  
  %% Select events
  
  % % debug
  % cfg = [];
  % cfg.dataset = infile_ns;
  % cfg.trialdef.eventtype = '?';
  % allEv = ft_definetrial(cfg);
  
  % find out which events are in infile_ns and throw an error if eventValue
  % is not one of these
  cfg_noEv = [];
  cfg_noEv.dataset = infile_ns;
  cfg_noEv.trialdef.eventtype = '?';
  allEv = ft_definetrial(cfg_noEv);
  evVals = cell(size(allEv.event));
  for i = 1:length(allEv.event)
    evVals{i} = allEv.event(i).value;
  end
  evVals = unique(evVals);
  if ~ismember(eventValue,evVals)
    fprintf('The available event values in %s are: %s\n',infile_ns,sprintf(repmat('''%s'' ',1,length(evVals)),evVals{:}));
    error('%s is not in the EEG file. You should redefine exper.eventValues.',sprintf(repmat('''%s'' ',1,length(eventValue)),eventValue{:}));
  elseif ismember(eventValue,evVals)
    fprintf('You can safely ignore the warning about ''no trialfun was specified''.\n')
  end
  
  % set up for defining the trials based on file type
  cfg.trialdef.eventvalue = eventValue;
  cfg.trialdef.prestim = abs(exper.prepost(1)); % in seconds; must be positive
  cfg.trialdef.poststim = exper.prepost(2); % in seconds; must be positive
  if strcmpi(exper.eegFileExt,'sbin') || strcmpi(exper.eegFileExt,'raw') || strcmpi(exper.eegFileExt,'egis')
    cfg.trialfun = 'seg_trialfun';
    cfg.trialdef.eventtype = 'trial';
  elseif strcmpi(exper.eegFileExt,'set')
    cfg.trialfun = 'trialfun_general';
    cfg.trialdef.eventtype = 'trigger';
  end
  % define the trials
  try
    fprintf('Searching for %s trials...\n',sprintf(repmat('''%s'' ',1,length(eventValue)),eventValue{:}));
    cfg = ft_definetrial(cfg);
  catch ME
    % if there were zero trials for this event type
    if strfind(ME.message,'no trials were defined')
      fprintf('No %s events found!\n',sprintf(repmat('''%s'' ',1,length(eventValue)),eventValue{:}));
    end
    fprintf('Returning an empty dataset for %s. This will save an error file when running the ft_*analysis function.\n',cell2mat(eventValue));
    
    % set an empty cell and return to the calling function
    data.trial = {};
    return
  end
  
  %% Get the data and process it if necessary
  
  % get the actual data
  data = ft_preprocessing(cfg);
  
  % find out how many channels are in the data
  nChan_data = length(data.label);

  % find reference channel index
  if isnumeric(exper.refChan)
    refChanInd = false(size(elec.label));
    refChanInd(exper.refChan) = true;
  else
    refChanInd = ismember(elec.label,exper.refChan);
  end
  if isempty(find(refChanInd,1))
    error('Could not find reference channel.');
  end
  
  %% Check on channel information
  
  % check on whether we have the reference channel (we want to have it);
  %
  % The channel files included with FieldTrip have 3 "extra" (fiduciary)
  % channels defined, so we need to also check using an extra 3 chans
  % subtracted off
  if (nChan_data == nChan_elecfile - 1) || (nChan_data == nChan_elecfile - 4)
    % one less channel because we're checking to see if the reference
    % channel is missing
    error('This dataset is either not rereferenced or the reference channel was not exported. Go back and rereference or export the reference channel in Net Station before running this script!');
  elseif (nChan_data == nChan_elecfile || nChan_data == nChan_elecfile - 3)
    
    % grab data from all of the trials
    trialData = cat(3,data.trial{:});
    % check the variance across time for the reference channel
    if sum(var(trialData(refChanInd,:,:),0,2) ~= 0) == 0
      % if none of trials have a non-zero variance reference channel, then
      % it has not been rereferenced. Some trials may have zero variance
      % because of how bad trial rejection works in EP Toolkit (it zeros
      % out all channels for bad trials).
      %
      % var=0 means that the final (reference) electrode is flat and this
      % data set has not been (average) rereferenced
      error('This dataset is not rereferenced. Go back and rereference in Net Station before running this script!');
    else
      
      % has full number of channels and is already rereferenced (ref channel
      % is not flat); check multiple trials
      fprintf('Channels are already (average) rereferenced, as they should be.\n');
      
      % depending on whether the channel string was capitalized or lowercase
      % in the electrode template, make the data elec label match. This is
      % actually important for how FieldTrip deals with electrode numbers.
      %
      % TODO: We now always want to use capital letters, so this should
      % probably be changed.
      if strcmp(elec.label{ceil(nChan_data/2)}(1),'E')
        isCapital = 1;
      elseif strcmp(elec.label{ceil(nChan_data/2)}(1),'e')
        isCapital = 0;
      else
        warning([mfilename,':electrodeCapitalization'],'There is no ''E'' or ''e'' at the start of the electrode number! Going with uppercase.')
        isCapital = 1;
      end
      
      if isCapital
        % capitalize the E for each electrode, or add it in if it's not there
        for c = 1:nChan_data
          if strcmp(data.label{c}(1),'e')
            data.label{c} = upper(data.label{c});
          elseif ~strcmp(data.label{c}(1),'e') && ~strcmp(data.label{c}(1),'E')
            data.label{c} = ['E' data.label{c}];
          end
        end
      elseif ~isCapital
        % make sure the e for each electrode is lowercase, or add it in if
        % it's not there
        for c = 1:nChan_data
          if strcmp(data.label{c}(1),'E')
            data.label{c} = lower(data.label{c});
          elseif ~strcmp(data.label{c}(1),'e') && ~strcmp(data.label{c}(1),'E')
            data.label{c} = ['e' data.label{c}];
          end
        end
      end
      
      % set the last channel name to 'Cz' if that's what was set in
      % elec.label (e.g., instead of 'E129')
      if strcmp(elec.label{end},'Cz')
        if isCapital
          lastChanStr = sprintf('E%d',nChan_data);
        elseif ~isCapital
          lastChanStr = sprintf('e%d',nChan_data);
        end
        %lastChanStr = 'Cz';
        chanindx = find(strcmpi(data.label,lastChanStr));
        if ~isempty(chanindx)
          % set the label for the reference channel
          %data.label{chanindx} = elec.label{chanindx};
          data.label{chanindx} = elec.label{end};
        end
      end
    end
  else
    error('Not sure what to do about rereferencing!');
  end
  
  %% artifact rejection
  
  if ~rejArt
    fprintf('Not performing any artifact rejection.\n');
    badChan = {};
  else
    [data,badChan] = mm_ft_artifact(dataroot,subject,sesName,eventValue,ana,exper,elecfile,data);
  end
  
  badChanAllSes = unique(cat(2,badChanAllSes,badChan));
  
  %% if we're combining multiple sessions, add the data to the append struct
  if length(session) > 1
    append_data.(sesStr) = data;
  end
end % ses

%% Append sessions, if necessary
  
% run ft_appenddata if we're combining multiple sessions
if length(session) > 1
  sesStr = sprintf('ses_%s',session{1});
  append_str = sprintf('append_data.%s',sesStr);
  
  for ses = 2:length(session)
    sesStr = sprintf('ses_%s',session{ses});
    append_str = cat(2,append_str,sprintf(',append_data.%s',sesStr));
  end
  
  data = eval(sprintf('ft_appenddata([],%s);',append_str));
end

%% Separate the event values

% initialize the struct to return
ft_raw = struct;

if length(eventValue) > 1
  for evVal = 1:length(eventValue)
    
    cfg = [];
    % select the correct trials for this event value
    cfg.trials = data.trialinfo == evVal;
    
    if sum(cfg.trials) > 0
      fprintf('Selecting %d trials for %s...\n',sum(cfg.trials),eventValue{evVal});
      % get the data for only this event value
      ft_raw.(eventValue{evVal}) = ft_redefinetrial(cfg,data);
      fprintf('Done.\n');
    else
      fprintf('No trials found for %s!\n',eventValue{evVal});
      ft_raw.(eventValue{evVal}).trial = {};
      %keyboard
    end
  end
elseif length(eventValue) == 1
  ft_raw.(eventValue) = data;
end

end