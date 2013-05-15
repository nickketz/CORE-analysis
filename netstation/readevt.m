function [outdata,data] = readevt(infile,smprate)

% read NetStation evt files and return a data struct with the event info
%
% input :
%   infile : data file location
%   smprate : sample rate in Hz   
%
% output :
%   oudata : struct with event names, onset times, and other data
%   event specific data included in the evt
%

%infile = 'CORE 100 20120813 1808.evt';
in = fopen(infile);

linind = 0;
data = {};

%three header lines
fname = fgets(in);
timemode = fgets(in);
hdr = regexp(fgets(in),'\t','split');
hdr = hdr(~cellfun('isempty',strtrim(hdr)));
%get data
temp = fgets(in);
while temp ~=-1
    linind = linind+1;
    data{linind} = regexp(temp,'\t','split');
    
    temp = fgets(in);
end

nvars = length(hdr);
hdr = strtrim(hdr);
cats = unique(cellfun(@(c) c{strcmp(hdr,'Category')},data,'uni',false));

names = cellfun(@(c) c{strcmp(hdr,'Code')},data,'uni',false);
onset = cellfun(@(c) c{strcmp(hdr,'Onset')},data,'uni',false);
%convert onsets from str to ms
onsetms = zeros(size(onset));
onsetsmp = onsetms;
for ionset = 1:length(onset)
    hrs = str2double(onset{ionset}(2:3));
    mins = str2double(onset{ionset}(5:6));
    secs = str2num(onset{ionset}(8:end));
    
    % convert to ms so we can sort
    h_ms = hrs * (1000 * 60 * 60);
    m_ms = mins * (1000 * 60);
    s_ms = secs * 1000;
    onsetms(ionset) = h_ms + m_ms + s_ms;
    
    %conver to samples
    onsetsmp(ionset) = (onsetms(ionset)/1000)*smprate;
    
end


for inames = 1:length(cats)
    dataind = find(cellfun(@(c) strcmp(c{strcmp(hdr,'Category')},cats{inames}),data));
    linind = 0;    
    datanames = {};
    datavals = [];
    
    for idata = 1:length(dataind)
        dataline = data{dataind(idata)};
        linind = linind+1;
        varind = 0;
        for ivar = nvars+1:2:length(dataline)-1  
            if ~isempty(strtrim(dataline{ivar}))
                varind = varind+1;
                datanames{varind} = dataline{ivar};
                datavals(linind,varind) = str2double(dataline{ivar+1});
            end
        end
    end

    outdata.(cats{inames}).onset = onset(dataind)';
    outdata.(cats{inames}).onsetms = onsetms(dataind)';
    outdata.(cats{inames}).onsetsmp = onsetsmp(dataind)';
    outdata.(cats{inames}).names = names(dataind)';
    outdata.(cats{inames}).vars = datanames;
    outdata.(cats{inames}).vals = datavals;
    outdata.(cats{inames}).ind = dataind';
    
end
        


