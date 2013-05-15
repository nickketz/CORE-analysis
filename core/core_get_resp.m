%add testresp struct to ana
%add resp vector to end of trldata in exper
% to be run after classifier has been trained 
%
% WARNING: currently setup to look for best training performance from 1 to
% 2 seconds!!!!
% subjects 1 to 6 have long exposure to training images, all other subjects
% should not be run on this time window, script needs to be adjusted for
% later subject numbers
%
% WARNING doesn't save exper in AD file!!!! must run save 

experorig = exper;
anaorig = ana;
clear testresp newtrldata;

for isub = 1:6%length(exper.subjects) only first six subjects should be run on this script!!!!!
    cfg_rd =[];
    cfg_rd.sub = exper.subjects{isub};%'CORE 06';
    cfg_rd.cname = 'enetalpha.8';
    cfg_rd.frequency = [3 50];
    cfg_rd.conds = {{'Timg_Scene'},{'Timg_Face'}};
    %cfg_rd.conds = {{'Timg_Scene','Word_Green_Scene'},{'Timg_Face','Word_Green_Face'}};
    %cfg_rd.conds = {{'Word_Green_Scene'},{'Word_Green_Face'}};
    
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
    twin = [1 1.5];
    twin = t>twin(1) & t<twin(2);
    tempacc = 1./bi;%look for low bi score
    tempacc(~twin) = 0;
    [maxperf, imax] = max(tempacc);
    maxt = t(imax);
    stats = stats(i);
    
    fprintf('Max performance found at t=%.3f to %.3fsecs, acc=%.3f, and p=%.3f\n----\n',maxt,maxt+width,acc(imax),bi(imax));
    
%     %plot accurcies with binomial prob overlaid on top
%     figure('color','white');
%     plot(t,acc,'--og','markersize',10,'linewidth',3);
%     hold on
%     plot(t,bi,'-sb','markersize',10,'linewidth',3);
%     plot([maxt maxt],ylim,'--','color',[.5,.5,.5]);
%     plot([maxt+width,maxt+width],ylim,'--','color',[.5,.5,.5]);
%     ylim([0 .5]);
%     %xlim([.5 2]);
%     box off;
%     set(gca,'fontsize',18);
%     h= legend('Acc above chance','Prob of false positive');
%     set(h,'fontsize',12);
%     conds = regexprep(cat(2,cfg_rd.conds{:}),'_','');
%     mytitle = sprintf('%sVs%s\n%s',conds{1}, conds{2}, cfg_rd.sub);
%     title(mytitle);
    
%     %plot average of crossvalidation models
%     avgmodel = stats(imax).model{1}.weights;
%     for imodel = 2:length(stats(imax).model)
%         avgmodel = avgmodel + stats(imax).model{imodel}.weights;
%     end
%     avgmodel = avgmodel./imodel;
%     nk_ft_plotfeatures(stats(imax), avgmodel,ana);
%     
    
    
    %% load specific subject data
    subStr = cfg_rd.sub;%{'CORE 02'};
    [exper,ana,dirs,files,cfg_proc,cfg_pp,data_freq] = core_loadSubs(adFile, subStr);
    cfg_fb = [];
    cfg_fb.baseline = [-.3 -.1];
    cfg_fb.baselinetype = 'absolute';
    data_freq = nk_ft_baselinecorrect(data_freq,ana,exper,cfg_fb);
    
    %% probe classifier on new data using best performance from above
    
    conds = {{cfg_rd.conds{:}},{{'Word_Green_Scene','Word_Blue_Scene','Word_Red_Face'},{'Word_Green_Face','Word_Blue_Face','Word_Red_Scene'}}};
    %train/test - labels -
    ntrials = {};
    design = {};
    data = {};
    subNo = find(strcmp(exper.subjects,cfg_rd.sub));
    for itype = 1:length(conds)
        design{itype} = [];
        for ilabel = 1:length(conds{itype})
            for iconds = 1:length(conds{itype}{ilabel})
                ntrials{itype}{ilabel}(iconds) = size(data_freq.(conds{itype}{ilabel}{iconds}).sub(subNo).ses.data.powspctrm,1);
                design{itype} = [design{itype} ilabel*ones(1,ntrials{itype}{ilabel}(iconds))];
                data{itype}{ilabel}{iconds} = data_freq.(conds{itype}{ilabel}{iconds}).sub(subNo).ses.data;
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
    
    %train_dat = nk_ft_datprep(cfg_train,data{1}{:});
    
    %get test dat matrix
    cfg_test = [];
    cfg_test.frequency = stats(imax).cfg.frequency;
    cfg_test.latency = [.5 2];
    cfg_test.conds = conds{2};
    cfg_test.design = design{2};
    
    %test_dat = nk_ft_datprep(cfg_test,data{2}{:});
    
    %set probemodel cfg
    cfg_pm = [];
    cfg_pm.train = cfg_train;
    cfg_pm.test = cfg_test;
    
    cfg_pm.testlatencies = cfg_pm.test.latency(1):.04:cfg_pm.test.latency(2);
    cfg_pm.mva = stats(imax).cfg.mva;
    cfg_pm.subNo = subNo;
    
%     if exist('traindata','var')
%         cfg_pm.trainednet = traindata;
%     end
    
    [test_stat,traindata] = nk_ft_probemodel(cfg_pm, data_freq);
    test_result = nk_ft_evaluateprobe(test_stat,design{2});
    [exper,trldata] = core_addtrlresp(test_result,conds{2},ntrials{2},cfg_rd.sub,exper);
    %nk_ft_plotfeatures(traindata, traindata.trainednet.model.weights,ana);
    
    %make testresp struct, includes traindata and resp vector
    tempstruct.traindata = traindata;
    tempstruct.trainresult = stats;
    tempstruct.testdata = test_stat;
    tempstruct.testresult = test_result;
    tempstruct.conds = conds;
    tempstruct.trldata = trldata;
    tempstruct.cfg = cfg_pm;  
    
    if ~exist('testresp','var')%preallocate
        testresp(length(exper.subjects)+1) = tempstruct;
        testresp(end) = [];
    end
    testresp(isub) = tempstruct;
    

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
    savefile =  sprintf('pow_testresp_%s_%.3f_%.3f_%.3f_%.3f', cfg_rd.cname, cfg_rd.frequency, cfg_pm.train.latency);
    if strcmp(cfg_rd.avgoverfreq,'yes')
        savefile = [savedir '_avgt'];
    end
    if strcmp(cfg_rd.avgovertime,'yes');
        savefile = [savefile '_avgf'];
    end
    savefile = [savedir filesep savefile];
    fprintf('Saving testresp struct to:\n %s\n',savefile);
    mytestresp = testresp(isub);
    save(savefile,'mytestresp');

    %add subject to newtrldata struct
    if ~exist('newtrldata','var')%preallocate
        newtrldata(length(exper.subjects)+1) = trldata;
        newtrldata(end) = [];
    end
    newtrldata(isub) = trldata;
    
    %reset exper.subjects
    exper.subjects = exper.subjectsorig;
    exper = rmfield(exper,'subjectsorig');    
end
exper = experorig;
ana = anaorig;

%%warning doesn't save exper or ana in AD file!!!!
