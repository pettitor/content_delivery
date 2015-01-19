% clear

clear par stats

% add library

addpath('lib');
addpath('lib/randraw')
addpath('lib/snm');
addpath('lib/li13');
addpath('lib/boxModel');

constants;

%%%%% Parameters

%%% load default Parameters

parRBHORST;
%parSECD;

% YTSTATS = 3;
% par.demand_model = YTSTATS;
% par.sharing_model = YTSTATS;

%%% specify Parameter Study

cachesizeAS = [0 0.1 0.2];
cachesizeAS = 0.1;

cachesizeUSER = [1 2 4 8]% 16 32 64 128];
cachesizeUSER = 2

pcacheUSER = [0 0.1 0.2 0.4 0.8 1];
par.pcacheUSER = [0.01];

par.cachingstrategy = [LRU LRU];

par.nvids = 10000;

par.uploadrate = 0.001;

par.downloadrate = 10;

%for ll=[1 5 10 20 40 80]
%    par.maxitemsAS = ll;
for l=[3]
    
    par.RBHORSTprio = l;
%     
% for k=1:length(pcacheUSER)
%     
%     par.pcacheUSER = pcacheUSER(k);
    
for i=1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(i); % proportional to AS size

for j=1:length(cachesizeUSER)

    par.cachesizeUSER = cachesizeUSER(j);  % videos
    
%%%%%% Run simulation

%profile on
%matlabpool open 8
tic
stats = cdsim(par);
toc
%matlabpool close

%%% Save Results

end
end
end
%end
%end