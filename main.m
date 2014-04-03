% clear

clear par stats

% add library

addpath('lib');
addpath('lib/randraw')

%%%%% Parameters

%%% Resource size and distribution (CDN, caches, end-devices)

% still need good model for unada cache distribution among ASes
par.ASn = 50;

par.ASp = geopdf(0:(par.ASn-1), 0.1);
par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000;

cachesizeAS = [0 0.05 0.1 0.2];
cachesizeUSER = [1 2 3 4 5];

for k=[1 3]
for i=1:length(cachesizeAS)
par.cachesizeAS = cachesizeAS(i); % proportional to AS size
for j=1:length(cachesizeUSER)
par.cachesizeUSER = cachesizeUSER(j);  % videos

par.pcacheUSER = 0.1;

%%% Video bitrate / chunk-size distribution

% consider later on

%%% Caching strategy

%%% literature
% temporal locality Traverso CCR 2013
% cf. Valentina Martina Infocom 2014
% Sbihi ITC'25 cache cooperation

% descending by tier, i.e. tier 1, tier 2, ...

LRU = 1;
LFU = 2;
LRUAS = 3;
RANDOM = 4;
SLWND = 5;

par.cachingstrategy = [LRU k];

par.k = 10;

% Thresholds: prefetching, rarest/demanded, popular/niche

%%% Resource selection strategy

LOCAL = 1;
RANDOM = 2;

par.resourceselection = LOCAL;

%%% AS-Topology

% consider later on

%%% Application -> QoE-model

% consider later on

%%% User and Social Network

par.wallsize = 100;

fG = fopen('data/graph10000.txt');
CG = textscan(fG,'%f %f','CommentStyle','#');
fclose(fG);
n = max([CG{1}' CG{2}'])+1;
par.GF = sparse(CG{1}'+1, CG{2}'+1, ones(1,length(CG{1})), n, n);

% par.GF = rand(1000,1000)<0.3;

par.historysize = 100;

%%% Item specific content demand (temporal, spatial)

ZIPF = 1;
WALL = 2;
YTSTATS = 3;

par.demand_model = ZIPF;

par.alpha = 1+1; % global Zipf law popularity, consider a<1, a>1

% timelag between demands
par.ia_demand_rnd = 'exp';
par.ia_demand_par = [10];

% basic model from propagation based paper
par.pshare = 8e4/24/1923507; % 8e4 per day, consider time or user dependent
par.preshare = par.pshare/8; % 1e4 per day

par.pshare = 0.5;
par.preshare = 0.5;

par.betashare = 1/0.8906;
par.betareshare = 1/0.9519;

% timelag between shares
par.ia_share_rnd = 'gp';
par.ia_share_par = [1/1.5070 1 0];

% propagation size dependent on clustering coefficient ~ 150*exp(-5*x)

%%% Simulation Parameters

par.tmax = 1e2;

par.rand_stream = 'mt19937ar';
par.seed = 13;

%%%%%% Run simulation

%profile on
%matlabpool open 8
tic
stats = cdsim(par);
toc
%matlabpool close

%%% Save Results

save(['results/cdsim_' date '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) '.mat'], 'par', 'stats')

end
end
end