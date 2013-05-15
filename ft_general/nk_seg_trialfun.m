function trl = nk_seg_trialfun(cfg)

% convert single string into cell-array, otherwise intersection does not
% work as intended
if ischar(cfg.trialdef.eventvalue)
  cfg.trialdef.eventvalue = {cfg.trialdef.eventvalue};
end

% get the header and event information
hdr = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% offset should be negative
offsetSamp = round(-cfg.trialdef.prestim*hdr.Fs);
% duration should be 1 sample less than the whole length of an event
durationSamp = round((cfg.trialdef.poststim+cfg.trialdef.prestim)*hdr.Fs) - 1;
% TODO: should this be ceil instead of round?


% initialize the trl matrix
trl = [];
%trl = nan(length(ismember({event(:).value},cfg.trialdef.eventvalue)),4);
eventCount = zeros(1,length(cfg.trialdef.eventvalue));

for i = 1:length(event)
  if strcmp(event(i).type,cfg.trialdef.eventtype)
    %if ~isempty(intersect(event(i).value, cfg.trialdef.eventvalue))
    %keyboard
    %if strcmp(deblank(event(i).value),cfg.trialdef.eventvalue)
    if ismember(deblank(event(i).value),cfg.trialdef.eventvalue)
      
      % get the type of event for the trialinfo field
      if length(cfg.trialdef.eventvalue) > 1
        eventNumber = find(ismember(cfg.trialdef.eventvalue,deblank(event(i).value)));
        eventCount(eventNumber) = eventCount(eventNumber)+1;
        trlind = strcmp('trln',cfg.evt.(cfg.trialdef.eventvalue{eventNumber}).vars);
        trlNumber = cfg.evt.(cfg.trialdef.eventvalue{eventNumber}).vals(eventCount(eventNumber),trlind);
      else
        eventNumber = [];
        trlNumber = [];
      end
      
      % add this trial [beginning sample, ending sample, offset, evNum]
      trl = cat(1,trl,[event(i).sample, (event(i).sample + durationSamp), offsetSamp, eventNumber, trlNumber]);

    end
  end
end
for ievt = 1:length(cfg.trialdef.eventvalue)
    if size(cfg.evt.(cfg.trialdef.eventvalue{ievt}).vals,1) ~= sum(trl(:,end-1) == ievt)
        error('mismatched number of events found for condition %s!',cfg.trialdef.eventvalue{ievt});
    end
end
