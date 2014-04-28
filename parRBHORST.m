%%%%% Default parameters for RB-HORST like sim

%%% Resource size and distribution (CDN, caches, end-devices)

% still need good model for unada cache distribution among ASes
par.ASn = 50;

par.ASp = geopdf(0:(par.ASn-1), 0.1);
par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000;

par.cachesizeAS = 0.1; % proportional to AS size

par.cachesizeUSER = 5; % items

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

par.cachingstrategy = [LRU LRU];

% SLWND sliding window parameter
par.k = 10;

% LRUAS parameter, cache only if #items in AS < maxitemsAS
par.maxitemsAS = 50;

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


par.nuser = size(par.GF,1);
% par.GF = rand(1000,1000)<0.3;

par.historysize = 100;

par.ncategories = 4;

%%% Item specific content demand (temporal, spatial)
ZIPF = 1;
WALL = 2;
YTSTATS = 3;
SNM = 4;
LI13 = 5;

par.demand_model = LI13;

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

% SNM parameters
if (par.demand_model == SNM)
    par = addSNMParams(par);
elseif (par.demand_model == LI13)
    par = addLI13Params(par);
end

%%% Simulation Parameters

par.tmax = 1e2;

par.rand_stream = 'mt19937ar';
par.seed = 13;