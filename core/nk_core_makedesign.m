function mydesign = nk_core_makedesign(conds,ntrials)

%make new design matrix based on ntrails and conds

for itest = 1:length(conds)
    
    cat1ntrials = sum(ntrials{2}{1});
    cat2ntrials = sum(ntrials{2}{2});
    mydesign = nan(cat1ntrials+cat2ntrials,2);
    myind = 0;
    for itype = 1:length(conds{2})
        for icond = 1:length(conds{2}{itype})
            if ~isempty(strfind(conds{2}{itype}{icond},'Face'))
                mydesign(myind+1:myind+ntrials{2}{itype}(icond),1) = 2;
            else
                mydesign(myind+1:myind+ntrials{2}{itype}(icond),1) = 1;
            end
            
            name = tokenize(conds{2}{itype}{icond},'_');            
            switch name{2}
                case 'Green'
                    mydesign(myind+1:myind+ntrials{2}{itype}(icond),2) = 0;
                case 'Blue'
                    mydesign(myind+1:myind+ntrials{2}{itype}(icond),2) = 1;
                case 'Red'
                    mydesign(myind+1:myind+ntrials{2}{itype}(icond),2) = 2;
            end  
            myind = myind+ntrials{2}{itype}(icond);        
        end
    end
    mydesign = mydesign';
    
end





