function outdata = CORE_datread(fname)

%read subject dat file into variables
%
%   input:
%       subNo = subject number
%       ses = memory session [0 1 2]
%
%   output:
%       outdata = struc of data from dat file
%

%     
%             %Write trial result to file:
%             fprintf(datafilepointer,'%02i %s %i %i %s %s %s %i %f\n', ...
%                 subNo, ...
%                 phaselabel, ...
%                 rep,...
%                 trial, ...
%                 resp, ...
%                 imgnames{trial},...
%                 wordstims{stimmat(trial,1)},...
%                 ac, ...
%                 rt);

%fname = ['./data/CORE_' num2str(subNo,'%02i') '_' num2str(ses) '.dat'];

[jnk,pl,rep,trial,resp,imgname,word,ac,rt] = textread(fname,'%d %s %d %d %s %s %s %d %f','headerlines',2);



% outdata.phase = pl;
% outdata.rep = rep;
% outdata.trial = trial;
% outdata.resp = resp;
% outdata.imgname = imgname;
% outdata.word = word;
% outdata.ac = ac;
% outdata.rt = rt;

idx = strcmp(pl,'test') & rep==max(rep);
outdata.acc = ac(idx);
outdata.stim = trial(idx);

% reps = unique(outdata.rep);
% for i = 1:length(reps)
%     phaseind = strcmp(outdata.phase,'test');
%     repind = outdata.rep ==reps(i) & phaseind ==1;
%     ac = outdata.ac(repind);
%     repac(i)=mean(ac);
% end
% % figure('color','white')
% % plot(reps,repac,'--bo','linewidth',5);
% % set(gca,'fontsize',30);
% % xlabel('reps');
% % ylabel('percent correct');
% % ylim([0 1]);
% % box off