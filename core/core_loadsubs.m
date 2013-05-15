function [exper,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadsubs(adFile,subStr,datatype,eventValues)

%script to load data for specific subject(s), not full list specified in
%exper
%
%   input:
%      adFile = str, analysis details file with full path
%      subStr = cell array, subjects to hold on to
%      eventValues = conditions to load
%      datatype = data str pow, or conn
%
%   outputs in order:
%       exper,ana,dirs,files,cfg_proc,cfg_pp,data_freq
%

[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);

files.figFontName = 'Helvetica';
files.figPrintFormat = 'dpng';
files.figPrintRes = 300;
if ~isfield(exper,'subjectsorig')
    exper.subjectsorig = exper.subjects;
end
exper.subjects = exper.subjects(ismember(exper.subjects,subStr));

%% set up channel groups

% pre-defined in this function
ana = mm_ft_elecGroups(ana);

%% list the event values to analyze; specific to each experiment

ana.eventValues = {eventValues};

% make sure ana.eventValues is set properly
if ~iscell(ana.eventValues{1})
  ana.eventValues = {ana.eventValues};
end
if ~isfield(ana,'eventValues') || isempty(ana.eventValues{1})
  ana.eventValues = {exper.eventValues};
end

%% load in the subject data

[data_freq] = mm_ft_loadSubjectData(exper,dirs,ana.eventValues,datatype,1);

% %% decide who to kick out based on trial counts
% 
% % Subjects with bad behavior
% exper.badBehSub = {};
% 
% % exclude subjects with low event counts
% [exper] = mm_threshSubs(exper,ana,20);
% 
% 
% %% get trial data and event list
% 
% [trldata,evt] = core_gettrldata(data_freq,ana,dirs,exper);
