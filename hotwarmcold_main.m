%% TODO bw / rate
addpath('lib');

d = 86400; %sec

rr = 1; % requestrate
ur = 1/15; % uploadrate
sr = 1;% streamrate

s=[3 3 3 3];
p=[10 5 2 1 1];
p=p/sum(p);

X = hotwarmcold(p,s,rr,ur)
%%

constants;

par.nuser = 100000;

par.nvids = 100000; % video catalog size in videos

par.cachesizeAS = 1000; % proportional to video catalog size

par.cachenuser = 0;

par.cachesizeUSER = 4; % HR cache size in number of videos

par.ASn = 1;
par.ASp = [1];

%par.pcacheUSER = pcache;%0.0001; 

par.cachingstrategy = [LRU OPT];
par.manipulate = 0;

par.factor = 1;

par.Cstrat = LCE;

par.uploadrate = Inf;
par.BWthresh = 200;

% Thresholds: prefetching, rarest/demanded, popular/niche

%%% Resource selection strategy

LOCAL = 1;
RANDOM = 2;
RBHORST = 3;

par.resourceselection = LOCAL;

par.RBHORSTprio = 1;

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

par.ticksPerSecond = 1;

%distribution of video arrivals
par.ia_video_rnd = 'exp';

par.BWthresh = 200; % kbps per second; only download from UNaDa if bw > threshold 
par.BWthreshHD = 1000; % kbps per second; only download from UNaDa if bw > threshold 

par.duration = 5*60; % seconds

par.pHD = 0.0;
par.bitrate = 250; % kbps
par.bitrateHD = 1000; % kbps

%%%% Parameter Study
uploadrate = [200 400 600 800 1000 Inf] % unlimited bw, one item per (5,10,20,40) seconds

%cachenuser = [50 100 200 Inf];
%cisp = [0.001 0.01];
pcache = 10.^(-4.5:0.5:-1);

run = 1;
l = 1;

%matlabpool 4;

%for l = 1:10
        %clear stats
par.uploadrate = 800;

par.rand_stream = 'mt19937ar';
par.seed = 13;

        for k=1:length(pcache);           
        
            par.pcacheUSER = pcache(k);
            par.nHR = par.pcacheUSER*par.nuser;
            stats(k) = cdsim(par);

        end
%    save(['results/RBHOVERLAY_ZIPF_cnuser' num2str(cachenuseri) '_cisp' num2str(cispj) '_run' num2str(l) '.mat'], 'stats')    
%end

%%
for k=1:length(pcache);           
    hitrate(k) = sum(stats(k).cache_serve)/sum(~isnan(stats(k).watch));
    hitrate1(k) = sum(stats(k).cache_hit)/sum(stats(k).cache_access);
end