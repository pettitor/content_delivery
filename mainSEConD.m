% SEConD

% clear
clear par stats

% add librarys
addpath('lib');
addpath('lib/boxModel')
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
par.pcacheUSER = 0.01;

% descending by tier, i.e. tier 1, tier 2, ...
% SPSS: LRU, UNaDas: LRU
par.cachingstrategy = [LRU LRU];

par.cachenuser = 0;

par.Cstrat = LCD;

% resource selection strategy
par.resourceselection = LOCAL;

% number of users
par.nuser = 10000;

par.alpha = 0.8; % global Zipf law popularity

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

%%% Simulation Parameters

%distribution of video arrivals
par.demand_model = BOX;
par.sharing_model = BOX;

%parameters for box model, lifespanMode: SNM_Like
par.box.lifespan.percentage = [3.6 5.3 3.3 5.3 82.4];
par.box.lifespan.lifespan = [0,2;2,5;5,8;8,13;13,38];
%par.box.lifeSpanMode = SNM_Like;
%mean 10.60 days,  std 3.6614
par.box.lifeSpanMode = proofOfConcept;
%parameters for box model, lifespanMode: proofOfConcept
par.box.lifespan.mu = 7.3136;
par.box.lifespan.sigma = 0.0934;

par.rand_stream = 'mt19937ar';
par.seed = 13;

%currently: one tick of t = 1/96 day -> 15 min
par.ticksPerDay = 96;
par.ticksPerDay = 24*60;
par.ticksPerSecond = par.ticksPerDay/24/60/60;

% timelag between demands
%par.ia_demand_rnd = 'exp';

% consider par.tickPerDay
par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
par.ia_demand_par_seconds = 2*ones(1,24); % constant ia time in seconds
par.ia_demand_par = par.ia_demand_par_seconds * par.ticksPerSecond;

par.categories=[0.253 0.247 0.086 0.086 0.085 0.075 0.035 0.032 0.023 0.016 0.016 0.011 0.010 0.008 0.005 0.005 0.003 0.002 0.002];
par.ncategories = 4;

% warmup phase and sim time
par.twarmup = 0.25e5;
par.tmax = 1e5 + par.twarmup;
par.nrequests = (par.tmax)./par.ia_demand_par;

% 3 choices of UL/DL bandwidth - probabities of each choice
%first choice
%par.bw=struct('DL',768,'UL',128,'dstr',21.4); 

%second choice
%par.bw(2).DL=1536;
%par.bw(2).UL=384;
%par.bw(2).dstr=23.3;

%third choice
%par.bw(3).DL=3072;
%par.bw(3).UL=768;
%par.bw(3).dstr=55.3;

par.BWthresh = 200; % kbps per second; only download from UNaDa if bw > threshold 
par.BWthreshHD = 1000; % kbps per second; only download from UNaDa if bw > threshold 

par.duration = 5*60; % seconds

par.pHD = 0.0;
par.bitrate = 250; % kbps
par.bitrateHD = 1000; % kbps

%%%% Parameter Study
uploadrate = [200 400 600 800 1000 Inf] % unlimited bw, one item per (5,10,20,40) seconds
%uploadrate_psecond = 1./(5*2^5)
Y = NaN(length(uploadrate), 3);

QoE = NaN(length(uploadrate), 1);

BWthresh = [0 250 500 750];
for run=2:10;
    
    par.seed = 13+run;
    par.box.box = prepareBoxModel(par);

for j=1:length(BWthresh)
par.BWthresh = BWthresh(j);
for i=1:length(uploadrate)

% kbps
par.uploadrate = uploadrate(i);%-1;%1/60/5;

stats = cdsim(par);

Y(i,3) = 1-(sum(stats.cache_serve))/sum(stats.views);
Y(i,2) = sum(stats.cache_serve(1:par.ASn))/sum(stats.views);
Y(i,1) = sum(stats.cache_serve(par.ASn+1:end))/sum(stats.views);

QoE(i) = sum(stats.goodqoe == true) / sum(~isnan(stats.goodqoe));
end
save(['results/SEConD2_BOX_n1e4_stdd100_cAS' num2str(par.cachesizeAS) '_alpha' num2str(par.alpha) '_BWthresh' num2str(BWthresh(j)) '_run' num2str(run) '.mat'], 'Y', 'QoE')
end
end
%%
figure(111);hold all;
bar(Y,'stacked')
%%
ylabel('contribution')
xlabel('mean home router upload bandwidth [kbps]')
set(gca,'xtick',1:6,'xticklabel',{'200' ,'400', '600', '800', '1000', 'unlimited'})
legend('\theta = 0 kbps', '\theta = 250 kbps', '\theta = 500 kbps', '\theta = 750 kbps')
%%
figure(12);clf;box on;hold all;
par.alpha = 0.8;
BWthresh = [0 250 500 750];
color = copper(4);
symbol = {':o',':x',':d',':s'};
for j=1:length(BWthresh)
    qoe = nan(6,10);
    for run=1:10
    load(['results/SEConD2_BOX_n1e4_stdd100_cAS' num2str(par.cachesizeAS) '_alpha' num2str(par.alpha) '_BWthresh' num2str(BWthresh(j)) '_run' num2str(run) '.mat'])
    qoe(:,run) = QoE;
    end
    qoeci = nan(6,1);
    for k=1:6;
    [h, p, ci] = ttest(qoe(k,:),mean(qoe(k,:)));
    qoeci(k) = ci(2) - mean(qoe(k,:));
    end
%plot(1:6,QoE,symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
%plot(1:6,mean(qoe,2),symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
errorbar(1:6,mean(qoe,2),-qoeci,+qoeci,symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
end
%%
ylabel('amount of good QoE video sessions')
xlabel('mean home router upload bandwidth [kbps]')
set(gca,'xtick',1:6,'xticklabel',{'200' ,'400', '600', '800', '1000', 'unlimited'})
legend('\theta = 0 kbps', '\theta = 250 kbps', '\theta = 500 kbps', '\theta = 750 kbps')
%%
figure(13);clf;box on;hold all;
par.alpha = 0.8;
BWthresh = [0 250 500 750];
color = copper(4);
symbol = {':o',':x',':d',':s'};
for j=1:length(BWthresh)
    c = zeros(6,10);
    for run=1:10
    load(['results/SEConD2_BOX_n1e4_stdd100_cAS' num2str(par.cachesizeAS) '_alpha' num2str(par.alpha) '_BWthresh' num2str(BWthresh(j)) '_run' num2str(run)  '.mat'])
    c(:,run) = (Y(:,2))./(Y(:,1)+(Y(:,2))+(Y(:,3)));
    end
    cci = nan(6,1);
    for k=1:6;
    [h, p, ci] = ttest(c(k,:),mean(c(k,:)));
    cci(k) = ci(2) - mean(c(k,:));
    end
%plot(1:6,sumc/10,symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
%plot(1:6,(Y(:,2))./(Y(:,1)+(Y(:,2))+(Y(:,3))),symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
errorbar(1:6,mean(c,2),-cci,+cci,symbol{j},'LineWidth',2,'Color',color(j,:),'MarkerSize',10)
end
%%
ylabel('ISP cache contribution')
xlabel('mean home router upload bandwidth [kbps]')
set(gca,'xtick',1:6,'xticklabel',{'200' ,'400', '600', '800', '1000', 'unlimited'})
legend('\theta = 0 kbps', '\theta = 250 kbps', '\theta = 500 kbps', '\theta = 750 kbps')