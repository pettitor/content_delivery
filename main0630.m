% new clean main 30th of June
%% run with only one AS
clear par stats

% add library

addpath('lib');
addpath('lib/randraw')

constants

par.ASn = 1;

par.ASp = 1;

par.nvids = 10000; % video catalog

par.cachesizeAS = 0.001; % proportional to video catalog

par.cachesizeUSER = 5; % items

par.pcacheUSER = 0;

par.cachingstrategy = [LRU LRU];

par.resourceselection = LOCAL;

par.RBHORSTprio = 1;

par.wallsize = 100;
fG = fopen('data/graph10000.txt');
CG = textscan(fG,'%f %f','CommentStyle','#');
fclose(fG);
n = max([CG{1}' CG{2}'])+1;
par.GF = sparse(CG{1}'+1, CG{2}'+1, ones(1,length(CG{1})), n, n);
par.nuser = 1000;%size(par.GF,1);
% par.GF = rand(1000,1000)<0.3;
par.historysize = 100;
par.categories=[0.253 0.247 0.086 0.086 0.085 0.075 0.035 0.032 0.023 0.016 0.016 0.011 0.010 0.008 0.005 0.005 0.003 0.002 0.002];
par.ncategories = 4;

par.demand_model = ZIPF;
par.sharing_model = ZIPF;

b = 3/8; %c.f. Gerhards Paper, slope of ZIPF rank
par.alpha = 1+b; % global Zipf law popularity, consider a<1, a>1

%currently: one tick of t = 1/96 day -> 15 min
par.ticksPerDay = 96;
par.ticksPerSecond = par.ticksPerDay/24/60/60;

% timelag between demands
par.ia_demand_rnd = 'exp';

% consider par.tickPerDay
%par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
par.ia_demand_par_seconds = 3600*ones(1,24); % constant ia time in seconds
par.ia_demand_par = par.ia_demand_par_seconds*par.ticksPerSecond;

% % basic model from propagation based paper
% par.pshare = 8e4/24/1923507; % 8e4 per day, consider time or user dependent
% par.preshare = par.pshare/8; % 1e4 per day
% 
par.pshare = 0.5;
par.preshare = 0.5;
% 
% par.betashare = 1/0.8906;
% par.betareshare = 1/0.9519;
% 
% % timelag between shares
% par.ia_share_rnd = 'gp';
% par.ia_share_par = [1/1.5070 1 0];

% propagation size dependent on clustering coefficient ~ 150*exp(-5*x)

%%% Simulation Parameters
par.tmax = 1e2;

par.rand_stream = 'mt19937ar';
par.seed = 13;

cachesizeAS = [0.0001 0.001 0.01];
hitrate = NaN(1, length(cachesizeAS));
for i=1:length(cachesizeAS)
    par.cachesizeAS = cachesizeAS(i);
    stats = cdsim(par);
    hitrate(i) = stats.cache_hit(1)/stats.cache_access(1);
end
%% run without UNaDas
