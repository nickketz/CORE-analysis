function param = nk_myselparam(data)

% SELPARAM(DATA) extracts the fieldnames param of the structure data containing functional
% data, which have a dimensionality consistent with the dimord field in the data. Selparam
% is a helper function to selectdata


fn = fieldnames(data);
sel = false(size(fn));
for i=1:numel(fn)
  siz    = size(data.(fn{i}));
  nsiz   = numel(siz);
  sel(i) = (nsiz==ndim) && all(siz==dim);
end
param = fn(sel);

% some fields should be excluded
param = setdiff(param, {'time', 'freq', 'channel','inside','label'});
