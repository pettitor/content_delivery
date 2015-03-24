constants;

% add library

addpath('lib');
addpath('lib/randraw')
addpath('lib/boxModel')

%%%%% Default parameters for RB-HORST like sim

clear par
clear stats

%par.nuser = 1829425;
par.nuser = 1; 

%%% Resource size and distribution (CDN, caches, end-devices)

% model from Internet Cencus, c.f. Sebastian
par.ASn = 1;

par.alpha = 1.5;

a=exp(-par.alpha .* log(1:par.ASn));
zipfcdf = cumsum([0 a]);
zipfcdf = zipfcdf/zipfcdf(end);

par.AS = nan(1, par.nuser);
for i=1:par.nuser
    par.AS(i) = sum(rand()>zipfcdf)+1;
end
%par.AS = sum(~(ones(par.ASn,1)*rand(1,par.nuser)<zipfcdf'*ones(1,par.nuser)),1)+1;

par.ASp = a/sum(a);
%par.ASp = geopdf(0:(par.ASn-1), 0.1);
%par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000; % video catalog size in videos

par.cachesizeAS = 1; % proportional to video catalog size

par.cachesizeUSER = 4; % HR cache size in number of videos

par.pcacheUSER = 0;%0.001;%0.0001; 

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

par.resourceselection = LOCAL;

%%% Item specific content demand (temporal, spatial)

par.ticksPerDay = 2*24*60;
par.ticksPerSecond = par.ticksPerDay/24/60/60;

par.ia_demand_par_seconds = 2*22.5/1.5*ones(1,24);
par.ia_demand_par = mean(par.ia_demand_par_seconds) * par.ticksPerSecond;

par.demand_model = ZIPF2;
par.sharing_model = ZIPF2;

par.demand_model = BOX;
par.sharing_model = BOX;
par.box.lifeSpanMode = proofOfConcept;
%parameters for box model, lifespanMode: proofOfConcept
% from SNM paper
% mean 10.60 days,  std 3.6614
m = 10.60;
v = 3.6614*3.6614;
par.box.lifespan.mu = log((m^2)/sqrt(v+m^2));
par.box.lifespan.sigma = sqrt(log(v/(m^2)+1));

par.alpha = 0.99; % global Zipf law popularity, consider a<1, a>1

par.nvids = par.nvids * 1.5;

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

% timelag between demands
par.ia_demand_rnd = 'exp';

% propagation size dependent on clustering coefficient ~ 150*exp(-5*x)

%%% Simulation Parameters
par.twarmup = 0.5e5;
par.tmax = 1e5 + par.twarmup;

par.nrequests = (par.tmax)./par.ia_demand_par;

%distribution of video arrivals
par.ia_video_rnd = 'exp';

par.rand_stream = 'mt19937ar';

cachesizeAS = floor(10.^(0:0.5:4));

hitrate = nan(length(cachesizeAS), 3, 5);

alpha = [0.6 0.8 0.99];

% m = 1;
% v = 3.6614*3.6614;
% par.box.lifespan.mu = log((m^2)/sqrt(v+m^2));
% par.box.lifespan.sigma = sqrt(log(v/(m^2)+1));

for j=1:length(alpha);
for run=1:1
    for i=1:length(cachesizeAS)
par.alpha = alpha(j);
par.seed = 13+run*7;
par.cachesizeAS = cachesizeAS(i);

stats = cdsim(par);

hitrate(i,j,run) = stats.cache_hit(1) ./ stats.cache_access(1);

    end
end
end

save(['results/CacheBOXn' '_m' num2str(m) '.mat'], 'hitrate')
%%
clear par
clear stats

%%%%% Default parameters for RB-HORST like sim

%par.nuser = 1829425;
par.nuser = 1; 

%%% Resource size and distribution (CDN, caches, end-devices)

% model from Internet Cencus, c.f. Sebastian
par.ASn = 1;

par.alpha = 1.5;

a=exp(-par.alpha .* log(1:par.ASn));
zipfcdf = cumsum([0 a]);
zipfcdf = zipfcdf/zipfcdf(end);

par.AS = nan(1, par.nuser);
for i=1:par.nuser
    par.AS(i) = sum(rand()>zipfcdf)+1;
end
%par.AS = sum(~(ones(par.ASn,1)*rand(1,par.nuser)<zipfcdf'*ones(1,par.nuser)),1)+1;

par.ASp = a/sum(a);
%par.ASp = geopdf(0:(par.ASn-1), 0.1);
%par.ASp(end) = 1-sum(par.ASp(1:end-1));

par.nvids = 10000; % video catalog size in videos

par.cachesizeAS = 1; % proportional to video catalog size

par.cachesizeUSER = 4; % HR cache size in number of videos

par.pcacheUSER = 0;%0.001;%0.0001; 

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

par.resourceselection = LOCAL;

%%% Item specific content demand (temporal, spatial)

par.demand_model = ZIPF2;
par.sharing_model = ZIPF2;

par.alpha = 0.99; % global Zipf law popularity, consider a<1, a>1

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

cachesizeAS = floor(10.^(0:0.5:4));

hitrate = nan(length(cachesizeAS), 3, 5);

alpha = [0.6 0.8 0.99];

for j=1:length(alpha);
par.alpha = alpha(j);
a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);
    for run=1:1%5
        par.seed = 13+run*7;
    for i=1:length(cachesizeAS)
par.cachesizeAS = cachesizeAS(i);

stats = cdsim(par);

hitrate(i,j,run) = stats.cache_hit(1) ./ stats.cache_access(1);

    end
    end
end

save(['results/CacheZIPF' '.mat'], 'hitrate')
%%
figure(2);clf;box on;hold all
set(gca,'xscale','log')
load(['results/CacheZIPF' '.mat'])
marker = {'--*g','--dg','--xg'};
for i=1:3
    ydata = hitrate(:,:,1);
    plot(cachesizeAS, ydata(:,i),marker{i},'LineWidth',2,'MarkerSize',10);
    
end

load(['results/CacheBOX' '.mat'])
marker = {':*b',':db',':xb'};
for i=1:3
    ydata = hitrate(:,:,1);
    plot(cachesizeAS, ydata(:,i),marker{i},'LineWidth',2,'MarkerSize',10);
    
end
%%
load(['results/CacheBOX_m30' '.mat'])
marker = {':*b',':db',':xb'};
for i=1:3
    ydata = hitrate(:,:,1);
    plot(cachesizeAS, ydata(:,i),marker{i},'LineWidth',2,'MarkerSize',10);
    
end
%%
xlabel('cache size')
ylabel('cache hit rate')