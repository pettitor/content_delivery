%% Zipf-law
[n,bin] = histc(stats.watch(~isnan(stats.watch)),1:par.nvids);

[nviews, vid] = sort(n,'descend');

figure(1);clf;box on;hold all;
plot(nviews);

xlabel('views k');
ylabel('P(X > k)');
set(gca,'xscale','log','yscale','log');
%set(gca,'xscale','log');
%printfig(gcf, 'views')
%hold all;
%plot(1:max(n),(1:max(n)).^(-1/par.alpha))

%% validate Zipf-exponent
[n,bin] = histc(stats.watch(~isnan(stats.watch)),1:par.nvids);

figure(1);clf;box on;hold all;
plot(sort(n),1-(1:length(n))/length(n));

[nviews, vid] = sort(n,'descend');

xlabel('views k');
ylabel('P(X > k)');
set(gca,'xscale','log','yscale','log');
%set(gca,'xscale','log');
%printfig(gcf, 'views')
%hold all;
%plot(1:max(n),(1:max(n)).^(-1/par.alpha))
%% temporal locality
figure(2); clf; box on;

hold all;

dt = par.tmax/10;
t = 1:dt:par.tmax;
views = zeros(5,length(t));

for i=1:10

[n,bin] = histc(stats.t(stats.watch == vid(i)),t);

views(i,:) = n;

end

bar(t,views')

xlabel('views k');
ylabel('P(X > k)');
%set(gca,'xscale','log','yscale','log');
%set(gca,'xscale','log');
%printfig(gcf, 'views')

%%
figure(11);clf;box on;hold all;
[cn,bin] = histc(n,1:(max(n)+1));
plot(1:(max(n)+1),cn/sum(cn),'*');
plot(1:100,(1:100).^(-1/par.alpha-1))
ylabel('P(k)');
xlabel('views k');
set(gca,'xscale','log','yscale','log');
%%
figure(2);%clf;box on;hold all;
plot(sort(stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), 'descend'))
legend({'ISP', 'UNaDa'})
xlabel('cache rank');
ylabel('hit rate');
%set(gca,'yscale','log');
figure(3);%clf;box on;hold all;
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'.')
legend({'UNaDa'})
xlabel('cache rank');
ylabel('hit rate');
ylim([0 1]) 
%set(gca,'yscale','log');
%%
ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(1,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
%figure
hold all;
plot(sort(ISPcachecontrib,'descend'));
%plot(sort(DCcontrib,'descend'));

%% ISP cache size, hitrate
figure(4);clf;box on;hold all;
plot(histc(stats.AS, 1:50)*par.cachesizeAS, stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), '.')
xlabel('cache size');
ylabel('hit rate');
%% how are requests to ISP caches distributed?
figure(5);%clf;box on;hold all;
assize = histc(stats.AS, 1:par.ASn);
asaccess = stats.cache_access(stats.cache.type == 1);
plot(assize, asaccess,'.');
plot(assize, stats.cache_hit(stats.cache.type == 1),'.');
xlabel('AS size');
ylabel('cache access rate');

%% parameter study 1
constants

figure(4);clf;box on;hold all;
xlabel('cache size');
ylabel('hit rate');

figure(3);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');
ylim([0 1]) 

simdate1 = '02-Apr-2014';

cachestrat1 = '1_1';
cachestrat2 = '1_3';


cachesizeAS = [0 0.05 0.1 0.2];
cachesizeAS = [0.1];
cachesizeUSER = [1 2 3 4 5];
cachesizeUSER = [1 5];

color = copper(length(cachesizeUSER)+1);

for i=1:length(cachesizeAS)
par.cachesizeAS = cachesizeAS(i); % proportional to AS size
for j=1:length(cachesizeUSER)
par.cachesizeUSER = cachesizeUSER(j);  % videos

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' simdate1 '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) cachestrat1 '.mat'])

% ISP cache size, hitrate
figure(4);
plot(histc(stats.AS, 1:50)*par.cachesizeAS, stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), '.',...
    'Color', color(j,:))

figure(3);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'.',...
        'Color', color(j,:))

figure(4);
load(['results/cdsim_' simdate1 '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) cachestrat2 '.mat'])

plot(histc(stats.AS, 1:50)*par.cachesizeAS, stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), 'x',...
    'Color', color(j,:))

figure(3);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', color(j,:))


end
end
figure(3);
%legend({num2str(cachesizeUSER')})
legend({'m_u = 1, LRU', 'm_u = 1, LRUAS', 'm_u = 5, LRU', 'm_u = 5, LRUAS'})
figure(4);
%legend({num2str(cachesizeUSER')})
legend({'m_u = 1, LRU', 'm_u = 1, LRUAS', 'm_u = 5, LRU', 'm_u = 5, LRUAS'})

%% parameter study 2

figure(4);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(5);clf;box on;hold all;
xlabel('cache rank');
ylabel('serve rate');

figure(3);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');
ylim([0 1]) 

simdate1 = '10-Apr-2014';
%simdate1 = '12-Jun-2014';

%cachestrat1 = '1_1';
cachestrat2 = '1_3';

cachesizeAS = [0.2];

cachesizeUSER = [5];

maxitemsAS = [1:5 10 20 40 80];

color = copper(9);

for l=1:length(maxitemsAS)
for i=1:length(cachesizeAS)
par.cachesizeAS = cachesizeAS(i); % proportional to AS size
for j=1:length(cachesizeUSER)
par.cachesizeUSER = cachesizeUSER(j);  % videos

% ISP cache size, hitrate

figure(4);
load(['results/cdsim_' simdate1 '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) '_' cachestrat2 ...
    '_maxitemsAS' num2str(maxitemsAS(l)) '.mat'])

%load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' simdate1 '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) '_pcUSR' num2str(par.pcacheUSER) '_' cachestrat2 ...
%    '_maxitemsAS' num2str(maxitemsAS(l)) '_RBHORSTprio3.mat'])

plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', color(l,:))

figure(5);
plot(sort(stats.cache_serve(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', color(l,:))
    
end
end
end
%figure(3);
%legend({num2str(cachesizeUSER')})
%legend({'m_u = 1, LRU', 'm_u = 1, LRUAS', 'm_u = 5, LRU', 'm_u = 5, LRUAS'})

figure(4);
%legend({num2str(cachesizeUSER')})
%%legend({num2str(maxitemsAS')})

load(['results/cdsim_' '02-Apr-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) '1_1' ...
    '.mat'])

plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', 'red')

legend('LRU-AS 1','LRU-AS 2','LRU-AS 3','LRU-AS 4','LRU-AS 5','LRU-AS 10','LRU-AS 20','LRU-AS 40','LRU-AS 80','LRU')

figure(5);
plot(sort(stats.cache_serve(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', 'red')
%%
figure(4);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(5);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(6);clf;box on;hold all;
xlabel('1 / AS size');
ylabel('AS hit rate');

figure(7);clf;box on;hold all; xlabel('cache size'); ylabel('AS hit rate');
figure(8);clf;box on;hold all; xlabel('cache size'); ylabel('ISP cache contribution');
figure(9);clf;box on;hold all; xlabel('cache size'); ylabel('data center contribution');
figure(10);clf;box on;hold all;ylabel('system contribution');

constants

parRBHORST

AShitrate = NaN(length(cachesizeAS), length(nASuser));
ISPcachec = NaN(length(cachesizeAS), length(nASuser));
DCcontrib = NaN(length(cachesizeAS), length(nASuser));
SYScontrib = NaN(length(cachesizeAS), 1);

mc = NaN(3,3);

cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 3 4 5];
RBresourceselection = [1 2 3];

color = copper(3);

    par.RBHORSTprio = 1;
    
    
    par.cachingstrategy(2) = 1;

    par.cachesizeUSER = cachesizeUSER(5);  % videos
    
for i=1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(i); % proportional to AS size

    par.demand_model = ZIPF;
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' '10-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat']);

figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(1,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
ISPcachec(i,:) = ISPcachecontrib;

figure(5);
plot(1:par.ASn,ISPcachecontrib,'x',...
        'Color', color(i,:))


nASuser = histc(stats.AS, 1:par.ASn);
    
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'x',...
        'Color', color(i,:))
    
end
    
legend({'ISPcache 0%', 'ISPcache 10%', 'ISPcache 20%'})

figure(7); plot(cachesizeAS, mean(AShitrate,2),'.', 'Color', color(1,:));
%plot(cachesizeAS, median(AShitrate,2),'x', 'Color', color(1,:));
figure(8); plot(cachesizeAS, mean(ISPcachec,2),'.-', 'Color', color(1,:));
plot(cachesizeAS, median(ISPcachec,2),'x', 'Color', color(1,:));
figure(9); plot(DCcontrib','o', 'Color', color(1,:));
%plot(cachesizeUSER, median(ISPcachec,2),'x');
figure(10); plot(SYScontrib,'d', 'Color', color(1,:));
mc(1,:) = mean(ISPcachec,2);

    par.RBHORSTprio = 2;

for i=1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(i); % proportional to AS size

    par.demand_model = ZIPF;
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' '10-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat']);

figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'x',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(2,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
ISPcachec(i,:) = ISPcachecontrib;

figure(5);
plot(1:par.ASn,ISPcachecontrib,'o',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'o',...
        'Color', color(i,:))
end
figure(7); plot(cachesizeAS, mean(AShitrate,2),'.', 'Color', color(2,:));
%plot(cachesizeAS, median(AShitrate,2),'x', 'Color', color(2,:));
figure(8); plot(cachesizeAS, mean(ISPcachec,2),'.-', 'Color', color(2,:));
plot(cachesizeAS, median(ISPcachec,2),'x', 'Color', color(2,:));
figure(9); plot(DCcontrib','o', 'Color', color(2,:));
%plot(cachesizeUSER, median(ISPcachec,2),'x');
figure(10); plot(SYScontrib,'d', 'Color', color(2,:));
mc(2,:) = mean(ISPcachec,2);

    par.RBHORSTprio = 3;

for i=1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(i); % proportional to AS size

    par.demand_model = ZIPF;
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' '10-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat']);

figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'d',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(3,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
ISPcachec(i,:) = ISPcachecontrib;

figure(5);
plot(1:par.ASn,ISPcachecontrib,'d',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'d',...
        'Color', color(i,:))
    
end
figure(7); plot(cachesizeAS, mean(AShitrate,2),'.', 'Color', color(3,:));
plot(cachesizeAS, median(AShitrate,2),'x', 'Color', color(3,:));
figure(8); plot(cachesizeAS, mean(ISPcachec,2),'.-', 'Color', color(3,:));
%plot(cachesizeAS, median(ISPcachec,2),'x', 'Color', color(3,:));
figure(9); plot(DCcontrib','o', 'Color', color(3,:));
%plot(cachesizeUSER, median(ISPcachec,2),'x');
figure(10); plot(SYScontrib,'d', 'Color', color(3,:));
mc(3,:) = mean(ISPcachec,2);

set(gca,'XScale','Log')
set(gca,'YScale','Log')
xlim([1e-3 1])
%% RANDOM
    %par.RBHORSTprio = 3;

for i=1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(i); % proportional to AS size

    par.demand_model = ZIPF;
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' '10-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RANDOM'...
    '.mat']);

figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'*',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
end

figure(5);
plot(1:par.ASn,ISPcachecontrib,'*',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'*',...
        'Color', color(i,:))

end
%% ISPcache contribution
%% home router contribution probability USR

figure(4);clf;box on; hold all;
figure(5);clf;box on; hold all;
figure(6);clf;box on; hold all;

cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 3 4 5];
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13'};

LOCAL = 1;
RANDOM = 2;
RBHORST = 3;

pcacheUSER = [0 0.1 0.2 0.4 0.8 1];

par.cachesizeAS = 0.1; % proportional to AS size

par.RBHORSTprio = 1;

color = copper(length(pcacheUSER));

for i=1:length(pcacheUSER)

    par.pcacheUSER = pcacheUSER(i);

    par.demand_model = ZIPF;

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' '10-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_pcUSR' num2str(par.pcacheUSER) ...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat']);

figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'*',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
end

figure(5);
plot(1:par.ASn,ISPcachecontrib,'*',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'*',...
        'Color', color(i,:))

end
%% maxitemsAS RBHORST
constants

parRBHORST

cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 3 4 5];

pcacheUSER = [0.1];
%par.resourceselection = RANDOM;

par.cachingstrategy = [LRU LRUAS];

color = copper(6);

figure(4);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(5);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(6);clf;box on;hold all;
xlabel('1 / AS size');
ylabel('AS hit rate');

maxitemsAS = [1 5 10 20 40 80];

AShitrate = NaN(length(maxitemsAS), length(nASuser));

for i=1:length(maxitemsAS)
    par.maxitemsAS = maxitemsAS(i);
for l=3
    
    par.RBHORSTprio = l;
    
for k=1:length(pcacheUSER)
    
    par.pcacheUSER = pcacheUSER(k);
    
for iii=2%1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(iii); % proportional to AS size

for j=5%1:length(cachesizeUSER)

    par.cachesizeUSER = cachesizeUSER(j);  % videos

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_'...
    '12-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_pcUSR' num2str(par.pcacheUSER) ...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_maxitemsAS' num2str(par.maxitemsAS) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat'], 'par', 'stats')
    %'_RANDOM' ...
    %'_maxitemsAS' num2str(par.maxitemsAS) ...
    
    figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'*',...
        'Color', color(i,:))

ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
end

figure(5);
plot(1:par.ASn,ISPcachecontrib,'*',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
AShitrate(i,:) = stats.AS_hit./stats.AS_access;
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'*',...
        'Color', color(i,:))
end
end
end
end
end
%%
figure(7);clf; plot(maxitemsAS, mean(AShitrate,2),'.');hold on
plot(maxitemsAS, median(AShitrate,2),'x');
%% constant cachesize

constants

parRBHORST
cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 4 8 16 32 64 128];

pcacheUSER = [0 0.1 0.2 0.4 0.8 1];
pcacheUSER = [0.1];
%par.resourceselection = RANDOM;

par.cachingstrategy = [LRU LRU];

color = copper(8);

figure(4);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(5);clf;box on;hold all;
xlabel('cache rank');
ylabel('ISP cache contribution');

figure(6);clf;box on;hold all;
xlabel('1 / AS size');
ylabel('AS hit rate');

figure(7);clf;box on;hold all;
figure(8);clf;box on;hold all;
figure(9);clf;box on;hold all;
figure(10);clf;box on;hold all;

AShitrate = NaN(length(cachesizeUSER), length(nASuser));
ISPcachec = NaN(length(cachesizeUSER), length(nASuser));
DCcontrib = NaN(length(cachesizeUSER), length(nASuser));
SYScontrib = NaN(length(cachesizeUSER));

for l=3
    
    par.RBHORSTprio = l;
%     
% for k=1:length(pcacheUSER)
%     
%     par.pcacheUSER = pcacheUSER(k);
    
for j=2%1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(j); % proportional to AS size

for i=1:length(cachesizeUSER)

    par.cachesizeUSER = cachesizeUSER(i);  % videos
    par.pcacheUSER = 1/par.cachesizeUSER;

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_'...
    '12-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER)...
    '_pcUSR' num2str(par.pcacheUSER) ...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '_RBHORSTprio' num2str(par.RBHORSTprio) ...
    '.mat'], 'par', 'stats')
    %'_RANDOM' ...
    %'_maxitemsAS' num2str(par.maxitemsAS) ...
    
    
ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(i,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
ISPcachec(i,:) = ISPcachecontrib;

    figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'*',...
        'Color', color(i,:))

figure(5);
plot(1:par.ASn,ISPcachecontrib,'*',...
        'Color', color(i,:))

nASuser = histc(stats.AS, 1:par.ASn);
    
AShitrate(i,:) = stats.AS_hit./stats.AS_access;
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'*',...
        'Color', color(i,:))
set(gca,'XScale','Log')

SYScontrib(i) = sum(stats.cache_serve) / length(stats.watch);
end
end
end
%%
figure(7);clf; plot(cachesizeUSER, mean(AShitrate,2),'.','color','black');hold on
plot(cachesizeUSER, median(AShitrate,2),'x','color','black');
%%
figure(8);clf; plot(cachesizeUSER, mean(ISPcachec,2),'.','color','black');hold on
plot(cachesizeUSER, median(ISPcachec,2),'x','color','black');
%%
figure(9);clf; plot(DCcontrib','o');hold on
%plot(cachesizeUSER, median(ISPcachec,2),'x');
%%
figure(10);clf; plot(SYScontrib,'d');
%%
%% constant cachesize RANDOM2

constants

parRBHORST
cachesizeAS = [0 0.1 0.2];
cachesizeUSER = [1 2 4 8 16 32 64 128];

pcacheUSER = [0 0.1 0.2 0.4 0.8 1];
pcacheUSER = [0.1];
par.resourceselection = RANDOM2;

par.cachingstrategy = [LRU LRU];

color = copper(8);

figure(4);clf;box on;hold all;
xlabel('cache rank');
ylabel('hit rate');

figure(5);clf;box on;hold all;
xlabel('cache rank');
ylabel('ISP cache contribution');

figure(6);clf;box on;hold all;
xlabel('1 / AS size');
ylabel('AS hit rate');

nASuser = histc(stats.AS, 1:par.ASn);

AShitrate = NaN(length(cachesizeUSER), length(nASuser));
ISPcachec = NaN(length(cachesizeUSER), length(nASuser));
DCcontrib = NaN(length(cachesizeUSER), length(nASuser));
SYScontrib = NaN(length(cachesizeUSER));

for l=3
    
    par.RBHORSTprio = l;
%     
% for k=1:length(pcacheUSER)
%     
%     par.pcacheUSER = pcacheUSER(k);
    
for j=2%1:length(cachesizeAS)

    par.cachesizeAS = cachesizeAS(j); % proportional to AS size

for i=1:length(cachesizeUSER)

    par.cachesizeUSER = cachesizeUSER(i);  % videos
    par.pcacheUSER = 1/par.cachesizeUSER;

load(['results/cdsim_demandModel_' char(demandModel(par.demand_model)) '_' char(resourceSel(par.resourceselection))...
    '16-Jun-2014' '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) ...
    '_pcUSR' num2str(par.pcacheUSER) ...
    '_' num2str(par.cachingstrategy(1)) '_' num2str(par.cachingstrategy(2)) ...
    '.mat'], 'par', 'stats')
    %'_RBHORSTprio' num2str(par.RBHORSTprio) ...
    %'_RANDOM' ...
    %'_maxitemsAS' num2str(par.maxitemsAS) ...
    
    
ISPcachecontrib = zeros(par.ASn, 1);
for ii = 1:par.ASn
    ISPcachecontrib(ii) = stats.cache_hit(ii) / sum(stats.cache_hit(stats.cache.AS == ii));
    DCcontrib(i,ii) = sum(stats.cache_serve(stats.cache.AS == ii)) / sum(ismember(stats.uid(~isnan(stats.watch)), find(stats.AS == ii)));
end
ISPcachec(i,:) = ISPcachecontrib;

    figure(4);
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'*',...
        'Color', color(i,:))

figure(5);
plot(1:par.ASn,ISPcachecontrib,'*',...
        'Color', color(i,:))
  
AShitrate(i,:) = stats.AS_hit./stats.AS_access;
figure(6);
plot(1./nASuser, stats.AS_hit./stats.AS_access,'*',...
        'Color', color(i,:))
set(gca,'XScale','Log')

SYScontrib(i) = sum(stats.cache_serve) / length(stats.watch);
end
end
end
%%
figure(7); plot(cachesizeUSER, mean(AShitrate,2),'.','color','red');hold on
plot(cachesizeUSER, median(AShitrate,2),'x','color','red');
%%
figure(8); plot(cachesizeUSER, mean(ISPcachec,2),'.','color','red');hold on
plot(cachesizeUSER, median(ISPcachec,2),'x','color','red');
%%
figure(9); plot(DCcontrib','o');hold on
%plot(cachesizeUSER, median(ISPcachec,2),'x');
%%
figure(10); plot(SYScontrib,'d');