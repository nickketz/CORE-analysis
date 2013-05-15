function mm_ft_contrastTFR(cfg_ft,cfg_plot,ana,files,dirs,data)
%MM_FT_CONTRASTTFR plot (and save) contast topoplots of time-freq data
%
%   mm_ft_contrastTFR(cfg_ft,cfg_plot,ana,files,dirs,data)
%
% Inputs:
%   cfg_ft: parameters passed into the FT plotting function
%
%   cfg_plot.ftFxn      = FieldTrip plotting function to use. Supported
%                         functions: ft_singleplotTFR, ft_topoplotTFR, and
%                         ft_multiplotTFR
%   cfg_plot.conditions = Cell array containing cells of pairwise
%                         comparisons; Can be used for comparing a subset
%                         of events within a type.
%                         e.g., {{'T1a','T1c'}, {'T2a','T2c'}}, or it can
%                         be {{'all_within_types'}} or
%                         {{'all_across_types'}} to automatically create
%                         pairwise comparisons of event values. See
%                         MM_FT_CHECKCONDITIONS for more details.
%   cfg_plot.plotTitle  = 1 or 0. Whether to plot the title.
%   cfg_plot.subplot    = 1 or 0. Whether to make a subplot. cfg_ft.xlim
%                         can be a range of time values, otherwise 50ms
%                         steps between min and max. ft_topoplotER only.
%   cfg_plot.numCols    = If subplot == 1, the number of columns to plot
%   files.saveFigs     = 1 or 0. Whether to save the figures.
%
%   data                = output from ft_freqgrandaverage
%
% See also:
%   MM_FT_CHECKCONDITIONS

if ~isfield(cfg_ft,'zparam')
  error('Must specify cfg_ft.zparam, denoting the data to plot (e.g., ''avg'' or ''individual'')');
end

if ~isfield(cfg_plot,'plotTitle')
  cfg_ft.plotTitle = 0;
end

cfg_plot.type = strrep(strrep(cfg_plot.ftFxn,'ft_',''),'plotTFR','');

if (strcmp(cfg_plot.type,'multi') || strcmp(cfg_plot.type,'topo'))
  % need a layout if doing a topo or multi plot
  cfg_ft.layout = ft_prepare_layout([],ana);
  
  if ~isfield(cfg_plot,'roi')
    % use all channels in a topo or multi plot
    cfg_plot.roi = {'all'};
  end
  
  if strcmp(cfg_plot.type,'topo')
    if isfield(cfg_ft,'showlabels')
      % not allowed
      cfg_ft = rmfield(cfg_ft,'showlabels');
    end
    if isfield(cfg_ft,'markerfontsize')
      cfg_ft.markerfontsize = 9;
    end
  end
end

% make sure conditions are set correctly
if ~isfield(cfg_plot,'condMethod')
  if ~iscell(cfg_plot.conditions) && (strcmp(cfg_plot.conditions,'all') || strcmp(cfg_plot.conditions,'all_across_types') || strcmp(cfg_plot.conditions,'all_within_types'))
    cfg_plot.condMethod = 'pairwise';
  elseif iscell(cfg_plot.conditions) && ~iscell(cfg_plot.conditions{1}) && length(cfg_plot.conditions) == 1 && (strcmp(cfg_plot.conditions{1},'all') || strcmp(cfg_plot.conditions{1},'all_across_types') || strcmp(cfg_plot.conditions{1},'all_within_types'))
    cfg_plot.condMethod = 'pairwise';
  elseif iscell(cfg_plot.conditions) && iscell(cfg_plot.conditions{1}) && length(cfg_plot.conditions{1}) == 1 && (strcmp(cfg_plot.conditions{1},'all') || strcmp(cfg_plot.conditions{1},'all_across_types') || strcmp(cfg_plot.conditions{1},'all_within_types'))
    cfg_plot.condMethod = 'pairwise';
  else
    cfg_plot.condMethod = [];
  end
end
cfg_plot.conditions = mm_ft_checkConditions(cfg_plot.conditions,ana,cfg_plot.condMethod);
% make sure conditions are set up for the for loop
if ~isfield(cfg_plot,'types')
  cfg_plot.types = repmat({''},size(cfg_plot.conditions));
end

% set the channel information
if ~isfield(cfg_plot,'roi')
  error('Must specify either ROI names or channel names in cfg_plot.roi');
elseif isfield(cfg_plot,'roi')
  if ismember(cfg_plot.roi,ana.elecGroupsStr)
    % if it's in the predefined ROIs, get the channel numbers
    if strcmp(cfg_plot.type,'topo')
      cfg_ft.highlight = 'on';
      cfg_ft.highlightsize = 10;
      cfg_ft.highlightchannel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,cfg_plot.roi)});
    else
      cfg_ft.channel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,cfg_plot.roi)});
    end
    % set the string for the filename
    cfg_plot.chan_str = sprintf(repmat('%s_',1,length(cfg_plot.roi)),cfg_plot.roi{:});
  else
    % otherwise it should be the channel number(s) or 'all'
    if ~iscell(cfg_plot.roi)
      cfg_plot.roi = {cfg_plot.roi};
    end
    
    if strcmp(cfg_plot.type,'topo')
      if ~strcmp(cfg_plot.roi,'all')
        cfg_ft.highlight = 'on';
        cfg_ft.highlightsize = 10;
        cfg_ft.highlightchannel = cfg_plot.roi;
      end
    else
      cfg_ft.channel = cfg_plot.roi;
    end
    
    % set the string for the filename
    cfg_plot.chan_str = sprintf(repmat('%s_',1,length(cfg_plot.roi)),cfg_plot.roi{:});
  end
end

% time
if isfield(cfg_ft,'xlim')
  if strcmp(cfg_ft.xlim,'maxmin')
    cfg_ft.xlim = [min(data.(cfg_plot.conditions{1}{1}).time) max(data.(cfg_plot.conditions{1}{1}).time)];
  end
else
  cfg_ft.xlim = [min(data.(cfg_plot.conditions{1}{1}).time) max(data.(cfg_plot.conditions{1}{1}).time)];
end

% set parameters for the subplot
if isfield(cfg_plot,'subplot')
  if cfg_plot.subplot
    if ~strcmp(cfg_plot.type,'topo')
      fprintf('Subplot only works with topoplot! Changing to non-subplot.\n');
      cfg_plot.subplot = 0;
    else
      if length(cfg_ft.xlim) > 2
        % predefined time windows
        cfg_plot.timeS = cfg_ft.xlim;
      else
        % default: 50 ms time windows
        cfg_plot.timeS = (cfg_ft.xlim(1):0.05:cfg_ft.xlim(2));
      end
      
      if ~isfield(cfg_plot,'numCols')
        cfg_plot.numCols = 5;
      end
      if (length(cfg_plot.timeS)-1) < cfg_plot.numCols
        cfg_plot.numCols = (length(cfg_plot.timeS)-1);
      end
      cfg_plot.numRows = ceil((length(cfg_plot.timeS)-1)/cfg_plot.numCols);
      
      % a few settings to make the graphs viewable
      cfg_ft.comment = 'xlim';
      cfg_ft.commentpos = 'title';
      cfg_ft.colorbar = 'no';
      cfg_ft.marker = 'on';
      if isfield(cfg_ft,'markerfontsize')
        cfg_ft = rmfield(cfg_ft,'markerfontsize');
      end
      cfg_plot.plotTitle = 0;
    end
  end
else
  cfg_plot.subplot = 0;
end

% freq
if isfield(cfg_ft,'ylim')
  if strcmp(cfg_ft.ylim,'maxmin')
    cfg_ft.ylim = [min(data.(cfg_plot.conditions{1}{1}).freq) max(data.(cfg_plot.conditions{1}{1}).freq)];
  end
else
  cfg_ft.ylim = [min(data.(cfg_plot.conditions{1}{1}).freq) max(data.(cfg_plot.conditions{1}{1}).freq)];
end

if strcmp(cfg_ft.colorbar,'yes')
  cfg_plot.colorbar_str = '_cb';
else
  cfg_plot.colorbar_str = '';
end

% initialize for storing the contrast topoplots
cont_plot = [];

for typ = 1:length(cfg_plot.conditions)
  % set the number of conditions that we're testing
  cfg_plot.numConds = size(cfg_plot.conditions{typ},2);
  
  vs_str = sprintf('%s%s',cfg_plot.conditions{typ}{1},sprintf(repmat('vs%s',1,cfg_plot.numConds-1),cfg_plot.conditions{typ}{2:end}));
  
  if cfg_plot.numConds > 2
    error('mm_ft_contrastTFR:numCondsGT2','Trying to compare %s, but this is a contrast plot and thus can only compare 2 conditions.\n',vs_str);
  end
  
  % create contrast
  cont_plot.(vs_str) = data.(cfg_plot.conditions{typ}{1});
  cont_plot.(vs_str).(cfg_ft.zparam) = data.(cfg_plot.conditions{typ}{1}).(cfg_ft.zparam) - data.(cfg_plot.conditions{typ}{2}).(cfg_ft.zparam);
  
  % make a plot
%  figure
  if cfg_plot.subplot
    for k = 1:length(cfg_plot.timeS)-1
      subplot(cfg_plot.numRows,cfg_plot.numCols,k);
      cfg_ft.xlim = [cfg_plot.timeS(k) cfg_plot.timeS(k+1)];
      feval(str2func(cfg_plot.ftFxn),cfg_ft,cont_plot.(vs_str));
    end
    % reset the xlim
    cfg_ft.xlim = [cfg_plot.timeS(1) cfg_plot.timeS(end)];
  else
    feval(str2func(cfg_plot.ftFxn),cfg_ft,cont_plot.(vs_str));
  end
  
  if ~isempty(cfg_plot.types{typ})
    set(gcf,'Name',sprintf('%s, %s - %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.types{typ},cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)))
  else
    set(gcf,'Name',sprintf('%s - %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)))
  end
  
  if strcmp(cfg_ft.zparam,'powspctrm')
    if strcmp(cfg_ft.colorbar,'yes')
      h = colorbar;
      set(get(h,'YLabel'),'string','Power');
    end
  elseif strcmp(cfg_ft.zparam,'cohspctrm')
    if strcmp(cfg_ft.colorbar,'yes')
      h = colorbar;
      set(get(h,'YLabel'),'string','Coherence');
    end
  end
  if cfg_plot.plotTitle
    %title(sprintf('%s - %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditionNames{c,1},cfg_plot.conditionNames{c,2},cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)));
    if isfield(cfg_plot,'roi_conn')
        title(sprintf('%s - %s, %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_plot.roi_conn,cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)));
    elseif isfield(cfg_ft,'refchannel')
        title(sprintf('%s - %s, %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_ft.refchannel,cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)));
    else
        title(sprintf('%s - %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)));
    end

%    title(sprintf('%s - %s, %.1f--%.1f Hz, %.1f--%.1f s',cfg_plot.conditions{typ}{1},cfg_plot.conditions{typ}{2},cfg_ft.ylim(1),cfg_ft.ylim(2),cfg_ft.xlim(1),cfg_ft.xlim(2)));
    publishfig(gca,0);
  end

  if files.saveFigs
    if ~isempty(cfg_plot.types{typ})
      cfg_plot.figfilename = sprintf('tfr_cont%s_ga_%s_%s_%s%d_%d_%d_%d%s.%s',cfg_plot.type,cfg_plot.types{typ},vs_str,cfg_plot.chan_str,cfg_ft.ylim(1),cfg_ft.ylim(2),round(cfg_ft.xlim(1)*1000),round(cfg_ft.xlim(2)*1000),cfg_plot.colorbar_str,files.figFileExt);
    elseif isfield(cfg_plot,'roi_conn')
        cfg_plot.figfilename = sprintf('tfr_cont%s_ga_%s_%s_%d_%d_%d_%d%s.%s',cfg_plot.type,vs_str,cfg_plot.roi_conn,cfg_ft.ylim(1),cfg_ft.ylim(2),round(cfg_ft.xlim(1)*1000),round(cfg_ft.xlim(2)*1000),cfg_plot.colorbar_str,files.figFileExt);
    else
        cfg_plot.figfilename = sprintf('tfr_cont%s_ga_%s_%s_%d_%d_%d_%d%s.%s',cfg_plot.type,vs_str,cfg_ft.refchannel,cfg_ft.ylim(1),cfg_ft.ylim(2),round(cfg_ft.xlim(1)*1000),round(cfg_ft.xlim(2)*1000),cfg_plot.colorbar_str,files.figFileExt);
    end

    dirs.saveDirFigsTopo = fullfile(dirs.saveDirFigs,['tfr_cont',cfg_plot.type]);
    if ~exist(dirs.saveDirFigsTopo,'dir')
      mkdir(dirs.saveDirFigsTopo)
    end
    print(gcf,files.figPrintFormat,fullfile(dirs.saveDirFigsTopo,cfg_plot.figfilename));
  end
end

end
