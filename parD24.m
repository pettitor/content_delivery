function stats = parD24(pcache, alpha, cachesizeAS, seed)

constants;

% add library

addpath('lib');
addpath('lib/randraw')

%%%%% Default parameters for RB-HORST like sim

par.nuser = 1829425;

%%% Resource size and distribution (CDN, caches, end-devices)

% model from Internet Cencus, c.f. Sebastian
par.ASn = 100;

par.alpha = 1.5;

a=exp(-par.alpha .* log(1:par.ASn));
zipfcdf = cumsum([a]);
zipfcdf = zipfcdf/zipfcdf(end);

par.AS = nan(1, par.nuser);
for i=1:par.nuser
    par.AS(i) = sum(rand()>zipfcdf)+1;
end
%par.AS = sum(~(ones(par.ASn,1)*rand(1,par.nuser)<zipfcdf'*ones(1,par.nuser)),1)+1;

%par.ASp = geopdf(0:(par.ASn-1), 0.1);
%par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 100000; % video catalog size in videos

par.cachesizeAS = cachesizeAS; % proportional to video catalog size

par.cachesizeUSER = 4; % HR cache size in number of videos

par.pcacheUSER = pcache;%0.001;%0.0001; 

par.cachingstrategy = [LRU LRU];

% SLWND sliding window parameter
par.k = 10;

% LRUAS parameter, cache only if #items in AS < maxitemsAS
par.maxitemsAS = 50;

% Thresholds: prefetching, rarest/demanded, popular/niche

%%% Resource selection strategy

LOCAL = 1;
RANDOM = 2;
RBHORST = 3;

par.resourceselection = LOCAL;

par.RBHORSTprio = 1;

%%% Item specific content demand (temporal, spatial)

par.demand_model = BOX;
par.sharing_model = BOX;

par.alpha = alpha; % global Zipf law popularity, consider a<1, a>1

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

% timelag between demands
par.ia_demand_rnd = 'exp';

% propagation size dependent on clustering coefficient ~ 150*exp(-5*x)

%%% Simulation Parameters
par.twarmup = 1e4;
par.tmax = 1e5 + par.twarmup;

%distribution of video arrivals
par.ia_video_rnd = 'exp';

par.rand_stream = 'mt19937ar';
par.seed = seed;

stats = cdsimD24(par);

