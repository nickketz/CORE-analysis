function [] = nk_ft_plotfeatures(mymodel,weights,ana)

% plot feature weights 
%   input:
%       mymodel = ft struc containing weight dimension info
%       weights = trained feature weights from the model
%       ana = analysis structure containing elec layout info
%

%mymodel = stats(imax);
%mymodel.vals = stats(imax).model{1}.weights;
%mymodel.vals = squeeze(reshape(trainednet.model.weights,mymodel.cfg.dim));
% plot
%stat.mymodel     = stat.model{1}.weights;
if sum(size(weights) ~= mymodel.dim(1:length(tokenize(mymodel.dimord,'_'))))
    mymodel.vals = squeeze(reshape(weights,squeeze(mymodel.cfg.dim)));
else
    mymodel.vals = weights;
end

cfg              = [];
cfg.layout       = ft_prepare_layout([],ana);
cfg.zparam       = 'vals';
cfg.comment      = '';
cfg.colorbar     = 'yes';
cfg.interplimits = 'head';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
figure('color','white');
ft_topoplotTFR(cfg,mymodel);
%ft_multiplotTFR(cfg,mymodel);
