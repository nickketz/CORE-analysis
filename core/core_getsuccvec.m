function trldata = core_getsuccvec(exper)

% adds 'succ' column to trldata, succ refers to whether the trial was
% successful or not in reference to the conditions' instructions
% i.e. nothink trials with an classifier output not matching the studied
% category type would be a '1' as in successfull, while think trial with
% misatching classifier output would be a '0'

for isub = 1:length(exper.trldata)
    trldata = exper.trldata(isub);
    fnames = fieldnames(trldata);
    for icond = 1:length(fnames)
        vars = trldata.(fnames{icond}).vars;
        if sum(strcmp('resp',vars))==0
            fprintf('subject %s has no resp column in their trldata for condition %s,skipping\n',exper.subjects{isub},fnames{icond});
            continue
        else
            vals = trldata.(fnames{icond}).vals; 
            
            %create new condition label based on classifier output
            condcol = find(strcmp('cond',vars));
            imgtcol = find(strcmp('imgt',vars));
            respcol = find(strcmp('resp',vars));
            
            faceinds = vals(:,imgtcol) == 1;
            sceneinds = vals(:,imgtcol) == 0;
            cong = union(find(vals(faceinds,respcol) == 1),find(vals(sceneinds,respcol) == 0));
            incong = union(find(vals(faceinds,respcol) == 0),find(vals(sceneinds,respcol) == 1));
            
            Redinds = find(vals(:,condcol) == 2);
            Blueinds = find(vals(:,condcol) == 1);
            Greeninds = find(vals(:,condcol) == 0);
            
            success = nan(size(vals,1),1);% succcessful in thinking or notthinking? 1=successful 0=unsuccessful
            
            success(intersect(Blueinds,incong)) = 0;
            success(intersect(Greeninds,incong)) = 0;
            success(intersect(Redinds,cong)) = 0;
            
            success(intersect(Blueinds,cong)) = 1;
            success(intersect(Greeninds,cong)) = 1;
            success(intersect(Redinds,incong)) = 1;
            
            %add column to trldata
            succcol = strcmp('succ',vars);
            if sum(succcol)==0
                trldata.(fnames{icond}).vars{end+1} = 'succ';
                trldata.(fnames{icond}).vals(:,end+1) = success;
            else
                trldata.(fnames{icond}).vals(:,succcol) = success;
            end
        end
    end
    exper.trldata(isub) = trldata;
end
trldata = exper.trldata;



