function [ data, ana] = nk_conddiff(data, ana, conddiff, param)
%Calculate a difference a two conditions to make a new one, to be used in
%interaction tests
%   input
%       data: data struc
%       cond:cell array of conditions strings to subtract
%       param: str of param to diff
%
%   output 
%       data: new data struc with diffed conditions
%


for i_conddiff = 1:length(conddiff)
    if isfield(data, conddiff{i_conddiff}{1}) && isfield(data, conddiff{i_conddiff}{2})
        cond1 = data.(conddiff{i_conddiff}{1});
        cond2 = data.(conddiff{i_conddiff}{2});
    else
        error('conditions not found');
    end
    newstr = [conddiff{i_conddiff}{1} 'vs' conddiff{i_conddiff}{2}];
    ana.eventValues{1}{end+1} = newstr;
    data.(newstr) = cond1;
    for sub = 1:length(cond1.sub)
        ses=1;
        newmat = cond1.sub(sub).ses(ses).data.(param) - cond2.sub(sub).ses(ses).data.(param);
        data.(newstr).sub(sub).ses(ses).data.(param) = newmat;
    end
end



