function ana = mm_ft_elecGroups(ana,layoutStr,elecGroupsExtra,elecGroupsStrExtra)
%MM_FT_ELECGROUPS Set up channel groups
%
% NB: ONLY DEFINED FOR HydroCel GSN!!!!
%
%   ana = mm_ft_elecGroups(ana,layoutStr,elecGroupsExtra,elecGroupsStrExtra)
%
%  Input:
%    ana                = the ana struct
%
%    layoutStr          = the layout to use (default: 'HCGSN129')
%
%    elecGroupsExtra    = Optional. Muse be a cell array containing cell
%                         arrays of strings of electrode labels, even if
%                         there is only one group.
%                         e.g., {{'E1','E2'},{'E3','E4'}}.
%
%    elecGroupsStrExtra = Optional. Identification strings for the groups.
%                         A cell array of strings, one for each group.
%
%  Output:
%    adds the elecGroups and elecGroupsStr fields to the ana struct
%
% NB: See the function code to view the pre-defined electrode groups
%
% NB: 'left', 'right', and 'anterior' exclude eye channels (above, below,
%     horizontal) and channels near the ears

if nargin == 4
  if (isempty(elecGroupsExtra) && ~isempty(elecGroupsStrExtra)) || (~isempty(elecGroupsExtra) && isempty(elecGroupsStrExtra))
    error('elecGroupsExtra and elecGroupsStrExtra both need to contain something.');
  elseif ~isempty(elecGroupsExtra) && ~isempty(elecGroupsStrExtra)
    if length(elecGroupsExtra) ~= length(elecGroupsStrExtra)
      error('elecGroupsExtra and elecGroupsStrExtra must be the same length.');
    end
  end
elseif nargin == 3
  error('Cannot define elecGroupsExtra without elecGroupsStrExtra');
end

if nargin < 4
  elecGroupsStrExtra = {};
  if nargin < 3
    elecGroupsExtra = {};
    if nargin < 2
      layoutStr = 'HCGSN129';
    end
  end
end

if strcmp('HCGSN129',layoutStr)
  right = [1:5, 9:10, 14, 76:80, 82:124];
  left = [7, 12:13, 18:24, 26:54, 56:61, 63:71, 73:74];
  midline = [6, 11, 15, 16, 17, 55, 62, 72, 75, 81];
  eyes_below = [127, 126]; % left, right
  eyes_above = [25, 8]; % left, right
  eyes_horiz = [128 125]; % left, right
  anterior = [1:7, 9:24, 26:30, 32:36, 38:40, 43:44, 104:106, 109:112, 114:118, 120:124];
  posterior = [31, 37, 41:42, 45:47, 49:103, 107:108, 113];
  center74 = [3 4 5 6 7 9 10 11 12 13 15 16 18 19 20 22 23 24 27 28 29 30 31 34 35 36 37 40 41 42 46 47 51 52 53 54 55 59 60 61 62 66 67 71 72 76 77 78 79 80 84 85 86 87 91 92 93 97 98 102 103 104 105 106 109 110 111 112 116 117 118 123 124];
  periph55 = [1 2 8 14 17 21 25 26 32 33 38 39 43 44 45 48 49 50 56 57 58 63 64 65 68 69 70 73 74 75 81 82 83 88 89 90 94 95 96 99 100 101 107 108 113 114 115 119 120 121 122 125 126 127 128];
  center91 = [2 3 4 5 6 7 9 10 11 12 13 15 16 18 19 20 22 23 24 26 27 28 29 30 31 33 34 35 36 37 39 40 41 42 45 46 47 50 51 52 53 54 55 58 59 60 61 62 65 66 67 70 71 72 75 76 77 78 79 80 83 84 85 86 87 90 91 92 93 96 97 98 101 102 103 104 105 106 108 109 110 111 112 115 116 117 118 122 123 124];
  periph38 = [1 8 14 17 21 25 32 38 43 44 48 49 56 57 63 64 68 69 73 74 81 82 88 89 94 95 99 100 107 113 114 119 120 121 125 126 127 128];
  all129 = (1:128);
  
  right = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(right)),right)));
  left = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(left)),left)));
  midline = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(midline)),midline)));
  midline = [midline, 'Cz'];
  eyes_below = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(eyes_below)),eyes_below)));
  eyes_above = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(eyes_above)),eyes_above)));
  eyes_horiz = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(eyes_horiz)),eyes_horiz)));
  anterior = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(anterior)),anterior)));
  posterior = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(posterior)),posterior)));
  center74 = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(center74)),center74)));
  center74 = [center74, 'Cz'];
  periph55 = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(periph55)),periph55)));
  center91 = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(center91)),center91)));
  center91 = [center91, 'Cz'];
  periph38 = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(periph38)),periph38)));
  all129 = eval(sprintf('{%s}',sprintf(repmat('''E%d'' ',size(all129)),all129)));
  all129 = [all129, 'Cz'];
  noEyeABH = all129(~ismember(all129,eyes_above) & ~ismember(all129,eyes_below) & ~ismember(all129,eyes_horiz));
  noEyeBH = all129(~ismember(all129,eyes_below) & ~ismember(all129,eyes_horiz));
  noEyeB = all129(~ismember(all129,eyes_below));
  noEyeH = all129(~ismember(all129,eyes_horiz));
  
  ana.elecGroups = {...
    {'E32','E33','E38','E39','E43','E44','E128'},... % LAI
    {'E1','E114','E115','E120','E121','E122','E125'},... % RAI
    {'E12','E13','E19','E20','E24','E28','E29'},... % LAS
    {'E4','E5','E111','E112','E117','E118','E124'},... % RAS
    {'E37','E42','E52','E53','E54','E60','E61'},... % LPS
    {'E78','E79','E85','E86','E87','E92','E93'},... % RPS
    {'E57','E58','E63','E64','E65','E68','E69'},... %LPI
    {'E89','E90','E94','E95','E96','E99','E100'},... % RPI
    {'E52','E53','E60','E61','E59','E66','E67'},... % LPS2
    {'E77','E78','E84','E85','E86','E91','E92'},... % RPS2
    {'E4','E10','E11','E15','E16','E18','E19'},... % Frontal Inferior
    {'E4','E5','E6','E11','E12','E13','E19','E112'},... % Frontal Superior
    {'E5','E6','E7','E12','E13','E106','E112'},... % Frontal Superior2
    {'E7','E31','E55','E80','E106','E129'},... % Central (central)
    {'E54','E61','E62','E67','E72','E77','E78','E79'},... % Posterior Superior
    {'E70','E71','E74','E75','E76','E82','E83'},... % Posterior Inferior
    {'E11'},... % Fz (frontocentral)
    {'Cz'},... % Cz (central)
    {'E75'},... % Oz - P1 effect (occipitocentral)
    {'E62'},... % Pz (posteriocentral)
    {'E64'},... % P9 - N1 effect? (left lateral)
    {'E95'},... % P10 - N1 effect? (right lateral)
    right,...
    left,...
    midline,...
    anterior,...
    posterior,...
    center74,...
    periph55,...
    center91,...
    periph38,...
    all129,...
    eyes_below,...
    eyes_above,...
    eyes_horiz,...
    noEyeABH,...
    noEyeBH,...
    noEyeB,...
    noEyeH,...
    };
  
  ana.elecGroupsStr = {...
    'LAI',...
    'RAI',...
    'LAS',...
    'RAS',...
    'LPS',...
    'RPS',...
    'LPI',...
    'RPI',...
    'LPS2',...
    'RPS2',...
    'FI',...
    'FS',...
    'FC',...
    'C',...
    'PS',...
    'PI',...
    'Fz',...
    'Cz',...
    'Oz',...
    'Pz',...
    'P9',...
    'P10',...
    'right',...
    'left',...
    'midline',...
    'anterior',...
    'posterior',...
    'center74',...
    'periph55',...
    'center91',...
    'periph38',...
    'all129',...
    'eyes_below',...
    'eyes_above',...
    'eyes_horiz',...
    'noEyeABH',...
    'noEyeBH',...
    'noEyeB',...
    'noEyeH',...
    };
end

if ~isempty(elecGroupsExtra)
  if sum(ismember(elecGroupsStrExtra,ana.elecGroupsStr)) > 0
    repeats = elecGroupsStrExtra(ismember(elecGroupsStrExtra,ana.elecGroupsStr));
    repeatsStr = sprintf(repmat('''%s'' ',1,sum(ismember(elecGroupsStrExtra,ana.elecGroupsStr))),repeats{:});
    error('elecGroupsStrExtra group(s) %salready exists in the predefined elecGroupsStr field. Unfortunately you need to rename the offending electrode group.',repeatsStr);
  end
  
  ana.elecGroups = cat(2,ana.elecGroups,elecGroupsExtra);
  ana.elecGroupsStr = cat(2,ana.elecGroupsStr,elecGroupsStrExtra);
end

if sum(size(ana.elecGroups) ~= size(ana.elecGroupsStr)) ~= 0
  error('The number of groups in ana.elecGroups (%d) is not the same as in ana.elecGroupsStr (%d).',size(ana.elecGroups),size(ana.elecGroupsStr))
end

end

% {'E62','E67','E71','E72','E75','E76','E77'},... % Posterior Inferior