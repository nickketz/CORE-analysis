function [newexper,trainresult,testresult] = core_makeRespVec(cfg,adFile)

%add testresp struct to ana
%add resp vector to end of trldata in exper
% to be run after classifier has been trained
%
% WARNING doesn't save exper in AD file!!!! must run save
%
%
%   input:
%       cfg:
%           subjects = list of subjets to get resp vector for
%           doplots = 1/0 do plots
%           savedata = save test results to file DOES NOT SAVE AD FILE!
%           cname = classifier name used in crossvalidated training
%           dobaseline = 0/1 do baseline correction from -.3 to -.1
%           testlatency = two value vector of start and end latency to test
%           testlatwidth = width between time points to test on
%           frequency = frequency range to train/test over(should be the
%             same as crossvalidated data)
%           trainconds = cell array of conditions used in CV training
%           testconds = cell array of conditions to get resp values for,
%             WARNING requires particular formatting to create design matrix
%             correctly
%       adFile = file with analysis details to load
%
%   output:
%       newexper = new exper structure
%       trainresult = results from best performing classifier
%       testresult = results from testing done on selected classifier
%
%

%load analysis details
[exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,false);
files.figFontName = 'Helvetica';
%files.figPrintFormat = 'png';
files.figPrintRes = 150;

cfg_rd = [];
cfg_rd.cname = cfg.cname;
cfg_rd.frequency = cfg.frequency;
cfg_rd.conds = cfg.trainconds;

if ~isfield(cfg,'runtest')
    cfg.runtest = 0;
end

%exper.subjects = cfg.subjects;
for isub = 1:length(cfg.subjects)
    
    cfg_rd.sub = cfg.subjects{isub};%'CORE 06';
    cfg_rd.statonly = 0;
    %cfg_rd.avgovertime = 'yes';
    
    stats = nk_ft_read_train_data(cfg_rd,dirs,exper);
    width = stats(1).cfg.latency(2) - stats(1).cfg.latency(1);
    if ~isfield(stats,'time');
        mycell = {stats.cfg};
        [t,i] = sort(cellfun(@(c) c.latency(1),mycell));
    else
        [t,i] = sort(cellfun(@(c) c(1),{stats.time}));
    end
    fprintf('\n---\nTraining data found for sub %s using network %s from t=%.3f to t=%.3f\n',cfg_rd.sub,cfg_rd.cname,min(t),max(t));
    acc = cellfun(@(c) c.accuracy, {stats.statistic});
    acc = acc(i);
    acc = acc-.5; % transform to percent above chance;
    bi = cellfun(@(c) c.binomial, {stats.statistic});
    bi = bi(i);
    
    %twin is time window to search for max performance
    twin = cfg.twin;%[1 1.5];
    twin = t>twin(1) & t<twin(2);
    tempacc = 1./bi;%look for low bi score
    tempacc(~twin) = 0;
    [maxperf, imax] = max(tempacc);
    maxt = t(imax);
    stats = stats(i);
    
    trainres.acc = acc(imax)+.5;
    trainres.bi = bi(imax);
    trainres.time = [stats(imax).time(1) stats(imax).time(end)];
    trainres.cfg = stats(imax).cfg;
    
    if ~exist('trainresult','var')
        trainresult = trainres;
    else
        trainresult(isub) = trainres;
    end
        
    fprintf('Max performance found at t=%.3f to %.3fsecs, acc=%.3f, and p=%.3f\n----\n',maxt,maxt+width,acc(imax),bi(imax));
    
    if cfg.doplots == 1
        %plot accurcies with binomial prob overlaid on top
        figure('color','white');
        plot(t,acc,'--og','markersize',10,'linewidth',3);
        hold on
        plot(t,bi,'-sb','markersize',10,'linewidth',3);
        plot([maxt maxt],ylim,'--','color',[.5,.5,.5]);
        plot([maxt+width,maxt+width],ylim,'--','color',[.5,.5,.5]);
        ylim([0 .5]);
        %xlim([.5 2]);
        box off;
        set(gca,'fontsize',18);
        h= legend('Acc above chance','Prob of false positive');
        set(h,'fontsize',12);
        conds = regexprep(cat(2,cfg_rd.conds{:}),'_','');
        mytitle = sprintf('%sVs%s\n%s',conds{1}, conds{2}, cfg_rd.sub);
        title(mytitle);
        %drawnow
        if cfg.saveplots ==1
            if files.figPrintFormat(1) ~= 'd'
                files.figPrintFormat = ['d' files.figPrintFormat];
            end
            figfilename = sprintf('pow_classify_%s_acc_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat);
            print(gcf,sprintf('-%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
            close all;
        end
        
        %plot average of crossvalidation models
        avgmodel = stats(imax).model{1}.weights;
        for imodel = 2:length(stats(imax).model)
            avgmodel = avgmodel + stats(imax).model{imodel}.weights;
        end
        avgmodel = avgmodel./imodel;
        nk_ft_plotfeatures(stats(imax), avgmodel,ana);
        %drawnow
        mytitle = sprintf('%sVs%s\n%s',conds{1}, conds{2}, cfg_rd.sub);
        title(mytitle);
        if cfg.saveplots ==1
            if files.figPrintFormat(1) ~= 'd'
                files.figPrintFormat = ['d' files.figPrintFormat];
            end
            figfilename = sprintf('pow_classify_%s_features_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat);
            print(gcf,sprintf('-%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
            close all;
        end
        
    end
    if cfg.runtest ==1
        
        %load specific subject data
        subStr = cfg_rd.sub;%{'CORE 02'};
        evts = cat(2,cfg.testconds{1}{:},cfg.testconds{2}{:});
        [ssexper,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadSubs(adFile, subStr,evts);
        if cfg.dobaseline == 1;
            cfg_fb = [];
            cfg_fb.baseline = [-.3 -.1];
            cfg_fb.baselinetype = 'absolute';
            data_freq = nk_ft_baselinecorrect(data_freq,ana,ssexper,cfg_fb);
        end
        
        % probe classifier on new data using best performance from above
        
        % cell struct for design matrix creation:
        % main two cells : {trainconds}, {testconds}
        % within test or train cells each cell specifies a condition label for
        % the classifier
        % within each condition label cell each cell is a TF condition which is
        % concatenated into a single label
        % must have same number of condition labels in train and test cells
        
        conds = cfg.testconds;% {{cfg_rd.conds{:}},{{'Word_Green_Scene','Word_Blue_Scene','Word_Red_Face'},{'Word_Green_Face','Word_Blue_Face','Word_Red_Scene'}}};
        %train/test - labels -
        ntrials = {};
        design = {};
        data = {};
        
        %make design matrix
        for itype = 1:length(conds)
            design{itype} = [];
            for ilabel = 1:length(conds{itype})
                for iconds = 1:length(conds{itype}{ilabel})
                    ntrials{itype}{ilabel}(iconds) = size(data_freq.(conds{itype}{ilabel}{iconds}).sub(1).ses.data.powspctrm,1);
                    design{itype} = [design{itype} ilabel*ones(1,ntrials{itype}{ilabel}(iconds))];
                    data{itype}{ilabel}{iconds} = data_freq.(conds{itype}{ilabel}{iconds}).sub(1).ses.data;
                end
            end
        end
        
        %get train dat matrix
        cfg_train = [];
        cfg_train.frequency = stats(imax).cfg.frequency;
        cfg_train.latency = stats(imax).cfg.latency;
        cfg_train.design = design{1};
        cfg_train.conds = conds{1};
        cfg_train.resample = true; %upsample deficient conditions to match trial numbers
        
        %get test dat matrix
        cfg_test = [];
        cfg_test.frequency = stats(imax).cfg.frequency;
        cfg_test.latency = cfg.testlatency;%[.5 2];
        cfg_test.conds = conds{2};
        cfg_test.design = design{2};
        
        %set probemodel cfg
        cfg_pm = [];
        cfg_pm.train = cfg_train;
        cfg_pm.test = cfg_test;
        
        cfg_pm.testlatencies = cfg_pm.test.latency(1):cfg.testlatwidth:cfg_pm.test.latency(2);
        cfg_pm.mva = stats(imax).cfg.mva;
        cfg_pm.subNo = 1;
        
        %retrain classifier on full training data from best performance, and
        %then get test output for test condtions
        [test_stat,traindata] = nk_ft_probemodel(cfg_pm, data_freq);
        mydesign = nk_core_makedesign(conds,ntrials);
        test_result = nk_ft_evaluateprobe_edit(test_stat,mydesign,cfg.method,cfg.doplots);              
        test_result.ntrials = ntrials;
        test_result.conds = conds;
        test_result.design = mydesign;
        
        myresult = core_probecondeval(test_result,0);  
        test_result.acc = myresult.acc;
        test_result.p = myresult.p;
        
        if ~exist('testresult','var')
            testresult = test_result;   
        else
            testresult(isub) = test_result;
        end

        if cfg.doplots
            title(sprintf('Subj %s',subStr));
            %drawnow
            if cfg.saveplots ==1
                if files.figPrintFormat(1) ~= 'd'
                    files.figPrintFormat = ['d' files.figPrintFormat];
                end
                figfilename = sprintf('pow_classify_%s_testval_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat);
                print(gcf,sprintf('-%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
                close all;
            end
        end
        
        [exper,trldata] = core_addtrlresp(test_result,conds{2},ntrials{2},cfg_rd.sub,exper);
        
        if cfg.doplots ==1
            nk_ft_plotfeatures(traindata, traindata.trainednet.model.weights,ana);
            title(sprintf('Full trained features\nsub %s',subStr));
            %drawnow;
            if cfg.saveplots ==1
                if files.figPrintFormat(1) ~= 'd'
                    files.figPrintFormat = ['d' files.figPrintFormat];
                end
                figfilename = sprintf('pow_classify_%s_fullfeatures_%s.%s',cfg.cname,exper.subjects{isub},files.figPrintFormat);
                print(gcf,sprintf('-%s',files.figPrintFormat),sprintf('-r%d',files.figPrintRes),fullfile(dirs.saveDirFigs,figfilename));
                close all;
            end
        end
        
        %make testresp struct, includes traindata and resp vector
        tempstruct.traindata = traindata;
        tempstruct.trainresult = stats;
        tempstruct.testdata = test_stat;
        tempstruct.testresult = test_result;
        tempstruct.conds = conds;
        tempstruct.trldata = trldata;
        tempstruct.cfg = cfg_pm;
        
        if ~exist('testresp','var')
            testresp(length(exper.subjects)+1) = tempstruct;
            testresp(end) = [];
        end
        subNo = find(strcmp(subStr,exper.subjects));
        testresp(subNo) = tempstruct;
        
        if cfg.savedata ==1;
            %save testresp as it is too large for AD file
            tempstr = {};
            for iconds = 1:length(cfg_rd.conds)
                tempstr{iconds} = sprintf('%s+',cfg_rd.conds{iconds}{:});
                tempstr{iconds} = tempstr{iconds}(1:end-1);
            end
            vsstr = sprintf('%sVs%s',tempstr{:});
            %set defaults
            cfg_rd.avgoverfreq = ft_getopt(cfg_rd, 'avgoverfreq', 'no');
            cfg_rd.avgovertime = ft_getopt(cfg_rd, 'avgovertime', 'no');
            savedir = fullfile(dirs.saveDirProc, cfg_rd.sub, 'pow_testresp');
            if ~exist(savedir,'dir')
                mkdir(savedir);
            end
            savefile =  sprintf('pow_classify_testresp_%s_%s_%.3f_%.3f_%.3f_%.3f', vsstr, cfg_rd.cname, cfg_rd.frequency, cfg_pm.train.latency);
            if strcmp(cfg_rd.avgoverfreq,'yes')
                savefile = [savedir '_avgt'];
            end
            if strcmp(cfg_rd.avgovertime,'yes');
                savefile = [savefile '_avgf'];
            end
            savefile = [savedir filesep savefile '.mat'];
            fprintf('Saving testresp struct to:\n %s\n',savefile);
            mytestresp = testresp(isub);
            if exist(savefile,'file')
                fprintf('WARNING file already exists, overwritting\n');
            end
            save(savefile,'mytestresp','trldata');
            fprintf('Done\n');
        end
        
        %         %add subject to newtrldata struct
        %         if ~exist('newtrldata','var')%preallocate
        %             newtrldata(length(exper.subjects)+1) = trldata;
        %             newtrldata(end) = [];
        %         end
        %         newtrldata(isub) = trldata;
        
    end
    
end
newtrldata = trldata;
newexper = exper;
%%warning doesn't save exper or ana in AD file!!!!
