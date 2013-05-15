function [exper,maxperf,subtestresult,subtestresp] = core_readprobetest(cfg,ana,dirs,exper,files)

subtestresp = {};
subtestresult = {};
for isub = 1:length(exper.subjects)
    mydir = fullfile(dirs.saveDirProc, exper.subjects{isub}, 'pow_testresp');
    myfiles = dir([mydir filesep 'pow_testresp_' cfg.cname '*']);
    myfiles = {myfiles.name};    
    testresp = [];
    testresult = [];
    myweights = {};
    perfdata =  [];%nan(length(myfiles),1);
    t = [];%nan(length(myfiles),2);
    fcnt = 0;
    fprintf('Loading %d files from %s...\n',length(myfiles),exper.subjects{isub});
    for ifile = 1:length(myfiles)
        indata = load([mydir filesep myfiles{ifile}]);
        if ismember({'testresp','trainednet'},fieldnames(indata))
            mydesign = nk_core_makedesign(indata.testresp.conds,indata.testresp.cfg.ntrials);
            newresult = nk_ft_evaluateprobe_newedit(indata.testresp.testdata,mydesign,cfg.method,0);   
            if newresult.error ==1
                fprintf('Data from probe t:%.03f to %.03f unusable\n',indata.testresp.cfg.train.latency);
            else
                fcnt = fcnt+1;
                newresult.ntrials = indata.testresp.cfg.ntrials;
                newresult.conds = indata.testresp.conds;
                newresult.design = mydesign;
                bootdata = core_probecondeval(newresult,0);
                newresult.acc = bootdata.acc;
                newresult.p = bootdata.p;
                if fcnt==1
                    testresp = indata.testresp;
                    testresult = newresult;
                    t = testresp.cfg.train.latency;
                else
                    testresp(fcnt) = indata.testresp;
                    testresult(fcnt) = newresult;
                    t(fcnt,:)= testresp(fcnt).cfg.train.latency;
                end
                perfdata(fcnt) = max(indata.trainednet.method{end}.performance);
                myweights{fcnt} = indata.trainednet.method{end}.model.weights;
            end
        end
    end
    %t = t(~isnan(t(:,1)),:);
    %perfdata = perfdata(~isnan(perfdata));
    twin = [];
    if isfield(cfg,'twin')
        twin = t(:,1)>cfg.twin(1) & t(:,1)<cfg.twin(2);
    else
        twin = ones(length(testresp));
    end
    twin = twin';
%     testacc = [testresult.acc].*twin;
%     testprob = [testresult.p].*twin;
    testauc = [testresult.auc];
    testauc = testauc(1,:).*twin;
    trainacc = perfdata.*twin;
    %[jnk,imax] = max((testacc+(testacc>.5 .*trainacc))./testprob);
    selstr = 'max(testauc.*(trainacc>.5))';
    [jnk,imax] = eval(selstr);
    maxt = t(imax,1);
    width = t(1,2) - t(1,1);
    acc = [testresult.acc] -.5;
    bi = [testresult.p];
    fprintf('------\nMax performance found for %s at %.03fs with:\n%f train performance\n%f validation performance\n%f falsepositive rate\nAUC: green: %.03f, blue: %.03f, red: %.03f\n------\n', ...
        exper.subjects{isub},maxt,perfdata(imax),acc(1,imax),bi(1,imax),testresult(imax).auc);

%    aucovertime
        
    if cfg.doplots ==1
        %plot accurcies with binomial prob overlaid on top
        figure('color','white');
        plot(t(:,1),acc,'--og','markersize',10,'linewidth',3);
        hold on
        plot(t(:,1),bi,'-sb','markersize',10,'linewidth',3);
        plot([maxt maxt],ylim,'--','color',[.5,.5,.5]);
        plot([maxt+width,maxt+width],ylim,'--','color',[.5,.5,.5]);
        ylim([0 .5]);
        %xlim([.5 2]);
        box off;
        set(gca,'fontsize',18);
        h= legend('Acc above chance','Prob of false positive');
        set(h,'fontsize',12);
        conds = regexprep(cat(2,testresp(1).cfg.test.conds{:}),'_','');
        mytitle = sprintf('%sVs%s\n%s',conds{1}, conds{4}, exper.subjects{isub});
        title(mytitle);
        
        %drawnow
        if cfg.saveplots ==1
            figfilename = sprintf('pow_testresp_%s_acc_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat);
            print(gcf,sprintf('-d%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
            close all;
        end
        
        %plot average of crossvalidation models
        nk_ft_plotfeatures(testresp(imax).traindata, myweights{imax},ana);
        title(exper.subjects{isub},'fontsize',15);
        %drawnow
        if cfg.saveplots ==1
            figfilename = sprintf('pow_testresp_%s_features_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat );
            print(gcf,sprintf('-d%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
            close all;
        end
    end

    %add resp column to trldata based on best performance
    [exper, trldata] = core_addtrlresp(testresult(imax), testresp(imax).cfg.test.conds,...
        testresp(imax).cfg.ntrials{2},exper.subjects{isub},exper);
        
    tempstruct.acc = testresult(imax).acc;
    tempstruct.t = t(imax,:);
    tempstruct.p = testresult(imax).p;
    tempstruct.auc = testresult(imax).auc;
    tempstruct.resp = testresult(imax).resp;
    tempstruct.imax = imax;
    tempstruct.trainperf = perfdata(imax);
    tempstruct.selstr = selstr;
    %tempstruct.weights = myweights{imax};
    
    if isub==1
        maxperf = tempstruct;
    else
        maxperf(isub) = tempstruct;
    end
    
    subtestresp{isub} = testresp;
    subtestresult{isub} = testresult;
    subtrldata{isub} = trldata;
    
end