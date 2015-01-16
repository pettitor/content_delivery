% clear

clear par stats

% add library

addpath('lib');
addpath('lib/randraw');
addpath('lib/snm');
addpath('lib/li13');

%%%%% Parameters

%%% load default Parameters

parRBHORST;

constants;

%% normal li
par.demand_model = MEME;
par.sharing_model = 0;

%par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
%par.ia_demand_par = par.ia_demand_par_seconds*par.ticksPerSecond;

par.ia_demand_par = ones(1,24);

%par.demand_model = ZIPF2;
%par.sharing_model = ZIPF2;

%par.alpha = alpha; % global Zipf law popularity, consider a<1, a>1

par.alpha = 0.99;

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

par.twarmup = 1e3;
par.tmax = par.twarmup + 1e4;

stats = cdsim(par);