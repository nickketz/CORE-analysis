function [newevt, bci, evt] = evtfilter(subNo,exper,ana,dirs)

% create new evt stuct that is filtered by the 'good' trials as identified
% in the bci file
%
%   input:
%       subNo = subject number
%       exper = experiment structure(needs subject labels)
%       ana = analysis structure(needs condition labels)
%       dirs = dirs structure(needs dataroot and dataDir)
%
%   output:
%       newevt = evt structure that has bad trials removed 
%

% get evt file
substr = [exper.subjects{subNo} '.*'];
evtdir = fullfile(dirs.dataroot, dirs.dataDir, 'ses1','ns_evt');
files = dir([evtdir filesep '*.evt']);
files = {files.name};
ind = find(~cellfun(@isempty,regexp(files, substr)));
if length(ind) == 1 
    evtfile = fullfile(evtdir, files{ind});
else
    error('multiple evt files found for %s\n',substr);
end
evt = readevt(evtfile,exper.sampleRate);
evt = core_filtevt(evt);

%get bci file
bcidir = fullfile(dirs.dataroot, dirs.dataDir, 'ses1','ns_bci');
files = dir([bcidir filesep '*.bci']);
files = {files.name};
ind = find(~cellfun(@isempty,regexp(files, substr)));
if length(ind) == 1 
    bcifile = fullfile(bcidir, files{ind});
else
    error('ambiguous bci files found for %s\n',substr);
end
bci = readbci(bcifile);
%%
%verify onset times matchup
%first find zero offset in bci files
firstonset = [];
for iconds = 1:length(ana.eventValues{1});
    firstonset = [firstonset bci.(ana.eventValues{1}{iconds}).onset(1)];
end
offset = evt.(ana.eventValues{1}{firstonset==0}).onsetms(1);
% compare each cond with corrected onset times
for iconds = 1:length(ana.eventValues{1})
    temp = evt.(ana.eventValues{1}{iconds}).onsetms - offset;
    %add corrected onset to struc
    evt.(ana.eventValues{1}{iconds}).onsetmscor = temp;
    %check against bci within 4ms match
    if sum(abs(temp-bci.(ana.eventValues{1}{iconds}).onset')>4) > 0
        error('Onsets don''t match for condition %s',ana.eventValues{1}{iconds});
    end
end

%% 
%filter evt based on 'good' bci events
for iconds = 1:length(ana.eventValues{1})
    mycond = (ana.eventValues{1}{iconds});
    good_ind = bci.(mycond).status == 1;
    newevt.(mycond) = evt.(mycond);
    fnames = fieldnames(newevt.(mycond));
    for ifields = 1:length(fnames);
        if size(newevt.(mycond).(fnames{ifields}),1) == length(good_ind)
            newevt.(mycond).(fnames{ifields}) = evt.(mycond).(fnames{ifields})(good_ind,:);
        end
    end    
end

