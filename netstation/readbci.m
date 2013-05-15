function [outdata,data] = readbci(infile,smprate)

% read NetStation bci files and return a data struct with the event info
%
% input :
%   infile : data file location
%   smprate : sample rate in Hz   
%
% output :
%   oudata : struct with event categories, onset times, segment# and event
%   status(good=1 bad=0)
%

%infile = 'CORE 100 20120813 1808.evt';
in = fopen(infile);

linind = 0;
data = {};

%one header line
hdr = regexp(fgets(in),'\t','split');

%get data
temp = fgets(in);
while temp ~=-1
    linind = linind+1;
    data{linind} = regexp(temp,'\t','split');    
    temp = fgets(in);
end

nvars = length(hdr);
cats = unique(cellfun(@(c) c{strcmp(hdr,'Category')},data,'uni',false));
onset = cellfun(@(c) c{strcmp(hdr,'StartTime')},data,'uni',false);
seg = cellfun(@(c) c{strcmp(hdr,'Seg#')},data,'uni',false);
status = cellfun(@(c) c{strcmp(hdr,'Status')},data,'uni',false);

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

    outdata.(cats{inames}).onset = str2double(onset(dataind));
    outdata.(cats{inames}).seg = seg(dataind);
    outdata.(cats{inames}).status = strcmp(status(dataind),'good');
    
end
        



