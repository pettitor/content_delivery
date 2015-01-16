% clear

clear par stats

% add library

addpath('lib');
addpath('lib/randraw')
addpath('lib/snm');
addpath('lib/li13');

%%%%% Parameters

%%% load default Parameters

parRBHORST;
%parSECD;

% YTSTATS = 3;
% par.demand_model = YTSTATS;
% par.sharing_model = YTSTATS;

%%% specify Parameter Study

cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 4 8 16 32 64 128];

LOCAL = 1;
RANDOM = 2;
RANDOM2 = 4;
RBHORST = 3;

pcacheUSER = [0 0.1 0.2 0.4 0.8 1];
pcacheUSER = [0.1];
par.resourceselection = RANDOM2;

par.cachingstrategy = [LRU LRU];

par.nvids = 10000;

par.uploadrate = 1;

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
    par.pcacheUSER = 1/par.cachesizeUSER;

%%%%%% Run simulation

%profile on
%matlabpool open 8
tic
stats = cdsim(par);
toc
%matlabpool close

%%% Save Results

ZIPF = 1;
WALL = 2;
YTSTATS = 3;
SNM = 4;
LI13 = 5;
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};
resourceSel = {'LOCAL','RANDOM','RBHORST','RANDOM2'};

save(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' char(resourceSel(par.resourceselection))...
    date '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_pcUSR' num2str(par.pcacheUSER) ...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '.mat'], 'par', 'stats')
    %'_RBHORSTprio' num2str(par.RBHORSTprio) ...
    %'_RANDOM' ...
    %'_maxitemsAS' num2str(par.maxitemsAS) ...
    
end
end
end
%end
%end