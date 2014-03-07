% add library

addpath('lib');

%%%%% Parameters

%%% Resource size and distribution (CDN, caches, end-devices)

% still need good model for unada cache distribution among ASes
par.ASn = 50;

par.ASp = geopdf(0:(par.ASn-1), 0.1);
par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000;

par.cachesize = [10]; % videos

%%% Video bitrate / chunk-size distribution

% consider later on

%%% Caching strategy

par.cachingstrategy = 'lru';

% Thresholds: prefetching, rarest/demanded, popular/niche

%%% Resource selection strategy

par.resourceselection = 'local';

%%% AS-Topology

% consider later on

%%% Application -> QoE-model

% consider later on

%%% User and Social Network

par.wallsize = 100;

% fG = fopen('data/graph10000.txt');
% CG = textscan(fG,'%f %f','CommentStyle','#');
% fclose(fG);
% n = max([CG{1}' CG{2}'])+1;
% par.GF = sparse(CG{1}'+1, CG{2}'+1, ones(1,length(CG{1})), n, n);

par.GF = rand(1000,1000)<0.4;

par.historysize = 100;

%%% Item specific content demand (temporal, spatial)

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

par.tmax = 1e3;

par.rand_stream = 'mt19937ar';
par.seed = 13;

%%%%%% Run simulation

stats = content_placement_sim(par);