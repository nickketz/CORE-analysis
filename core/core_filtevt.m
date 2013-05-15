function evt = core_filtevt(evt)

conds = {'Timg_Face','Timg_Scene'};
imgt = [1 0];
fnames = fieldnames(evt);
fprintf('Filtering condtions based on CORE experiment...\n');
for icond = 1:length(fnames)
    
    tempstruc = evt.(fnames{icond});
    
    %grab only unique trials numbers
    [jnk,ui] = unique(tempstruc.vals(:,2),'last');
    
    if sum(strcmp(fnames{icond}, conds))==1
        %find var cols
        corrcol = strcmp(tempstruc.vars,'corr');
        imgtcol = strcmp(tempstruc.vars,'imgt');
        condcol = strcmp(tempstruc.vars,'cond');
        
        %find good ind
        goodind = find(tempstruc.vals(:,corrcol) == 0 & tempstruc.vals(:,imgtcol) == imgt(strcmp(fnames{icond},conds))...
            & tempstruc.vals(:,condcol) == 0);
        goodind = intersect(ui,goodind);
    else
        goodind = ui;
    end
    fprintf('%s: all:%d, filtered:%d\n',fnames{icond},length(tempstruc.vals(:,2)),length(goodind));
    
        
    %create new evt struc using only good inds
    newstruc.onset = tempstruc.onset(goodind);
    newstruc.onsetms =  tempstruc.onsetms(goodind);
    newstruc.onsetsmp =  tempstruc.onsetsmp(goodind);
    newstruc.names =  tempstruc.names(goodind);
    newstruc.vals =  tempstruc.vals(goodind,:);
    newstruc.ind =  tempstruc.ind(goodind);
    newstruc.vars = tempstruc.vars;
    
    evt.(fnames{icond}) = newstruc;
    
end