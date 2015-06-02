function stats = parRBH(alpha, cisp, cachenuser, pcache, resourcesel, seed)

constants;

% add library

addpath('lib');
addpath('lib/randraw')

%%%%% Default parameters for RB-HORST like sim

%par.nuser = 1829425;
par.nuser = 100000;
%par.nuser = 267157;
%par.nuser = nuser; 

%%% Resource size and distribution (CDN, caches, end-devices)

fid = fopen('data/20150101.as-rel.txt');
C = textscan(fid, '%f %f %f', 'delimiter', '|', 'CommentStyle', '#');
fclose(fid);
ipeers = C{3}==0;
icustomer = C{3}==-1;

n = max([C{1};C{2}]);

par.peer = sparse(C{1}(ipeers),C{2}(ipeers), ones(1,sum(ipeers)), n, n);
par.peer = par.peer | par.peer';
par.customer = sparse(C{1}(icustomer),C{2}(icustomer), ones(1,sum(icustomer)), n, n);

% model from Internet Cencus, c.f. Sebastian
load 'data/asvalues.mat'

par.ASn = length(x);

par.ASp = y/sum(y);

% only use ripencc eu ASes
%ripencc|EU|asn|7|1|19930901|allocated
fid = fopen('data/delegated-ripencc-extended-latest');
D = textscan(fid, '%s %s %s %d %d %d %s', 'delimiter', '|', 'CommentStyle', '#','HeaderLines',56049);
fclose(fid);
ias = strcmp(D{3},'asn');
asneu = D{4}(ias);

[c, ia, ib] = intersect(asneu, 1:par.ASn);

par.ASp = par.ASp(asneu)/sum(par.ASp(asneu));

par.peer = par.peer(asneu, asneu);
par.customer = par.customer(asneu, asneu);

%cdf = cumsum(par.ASp);

% par.AS = nan(1, par.nuser);
% for i=1:par.nuser
%     par.AS(i) = sum(rand()>cdf)+1;
% end
%par.AS = sum(~(ones(par.ASn,1)*rand(1,par.nuser)<zipfcdf'*ones(1,par.nuser)),1)+1;
%%
%par.ASp = geopdf(0:(par.ASn-1), 0.1);
%par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 100000; % video catalog size in videos

par.cachesizeAS = cisp*par.nvids; % proportional to video catalog size

par.cachenuser = cachenuser;

par.cachesizeUSER = 5; % HR cache size in number of videos

par.pcacheUSER = pcache;%0.0001; 

par.cachingstrategy = [LRU LRU];

par.Cstrat = LCE;

par.uploadrate = Inf;
par.BWthresh = 200;

% SLWND sliding window parameter
par.k = 10;

% LRUAS parameter, cache only if #items in AS < maxitemsAS
par.maxitemsAS = 50;

% Thresholds: prefetching, rarest/demanded, popular/niche

%%% Resource selection strategy

LOCAL = 1;
RANDOM = 2;
RBHORST = 3;

par.resourceselection = resourcesel;

par.RBHORSTprio = 1;

%%% Item specific content demand (temporal, spatial)

par.demand_model = ZIPF2;
par.sharing_model = ZIPF2;

par.alpha = alpha; % global Zipf law popularity, consider a<1, a>1

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

% timelag between demands
par.ia_demand_rnd = 'exp';

% propagation size dependent on clustering coefficient ~ 150*exp(-5*x)

%%% Simulation Parameters
par.twarmup = 0.5e5;
par.tmax = 1e5 + par.twarmup;

%distribution of video arrivals
par.ia_video_rnd = 'exp';

par.rand_stream = 'mt19937ar';
par.seed = 13+seed;

stats = cdsim(par);
