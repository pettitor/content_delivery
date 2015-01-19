% SEConD

% clear
clear par stats

% add librarys
addpath('lib');
addpath('lib/randraw')

constants;

%%%%% Parameters

%%% load default Parameters

%%% specify Parameter Study

% number of ASes
par.ASn = 1;

% probability that user belongs to AS
par.ASp = geopdf(0:(par.ASn-1), 0.1);
par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000; % video catalog

par.cachesizeAS = 2000*ones(1,par.ASn); % items

par.cachesizeUSER = 2; % items

% probability that a user shares his UNaDa
par.pcacheUSER = 0.1;

% descending by tier, i.e. tier 1, tier 2, ...
% SPSS: LRU, UNaDas: LRU
par.cachingstrategy = [LRU LRU];

% resource selection strategy
par.resourceselection = LOCAL;

% number of users
par.nuser = 1000;

par.alpha = 0.85; % global Zipf law popularity

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

%%% Simulation Parameters
par.tmax = 1e4;

%distribution of video arrivals
par.demand_model = BOX;
par.sharing_model = BOX;

%parameters for box model, lifespanMode: SNM_Like
par.box.lifespan.percentage = [3.6 5.3 3.3 5.3 82.4];
par.box.lifespan.lifespan = [0,2;2,5;5,8;8,13;13,38];
%par.box.lifeSpanMode = SNM_Like;
par.box.lifeSpanMode = proofOfConcept;
%parameters for box model, lifespanMode: proofOfConcept
par.box.lifespan.mu = 7.3136;
par.box.lifespan.sigma = 0.0934;

par.rand_stream = 'mt19937ar';
par.seed = 13;

%currently: one tick of t = 1/96 day -> 15 min
par.ticksPerDay = 96;
par.ticksPerDay = 96*15;
par.ticksPerSecond = par.ticksPerDay/24/60/60;

% timelag between demands
%par.ia_demand_rnd = 'exp';

% consider par.tickPerDay
par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
par.ia_demand_par_seconds = 4*ones(1,24); % constant ia time in seconds
par.ia_demand_par = par.ia_demand_par_seconds * par.ticksPerSecond;

par.categories=[0.253 0.247 0.086 0.086 0.085 0.075 0.035 0.032 0.023 0.016 0.016 0.011 0.010 0.008 0.005 0.005 0.003 0.002 0.002];
par.ncategories = 4;

% warmup phase and sim time
par.twarmup = par.tmax/5;
par.nrequests = (par.twarmup+par.tmax)./par.ia_demand_par;

%%%% Parameter Study
uploadrate_psecond = [-1 1/2./(2.^(0:3))] % unlimited bw, one item per (5,10,20,40) seconds
Y = NaN(length(uploadrate_psecond), 3);
for i=1:length(uploadrate_psecond)

% items per second
par.uploadrate_psecond = uploadrate_psecond(i);%-1;%1/60/5;
% items per tick
par.uploadrate = par.uploadrate_psecond * par.ticksPerSecond;

stats = cdsim(par);

Y(i,3) = 1-(sum(stats.cache_serve))/sum(stats.views);
Y(i,2) = sum(stats.cache_serve(1:par.ASn))/sum(stats.views);
Y(i,1) = sum(stats.cache_serve(par.ASn+1:end))/sum(stats.views);

end
%%
%Y = NaN(3,3);


bar(Y,'stacked')