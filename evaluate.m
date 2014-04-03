[n,bin] = histc(stats.watch(~isnan(stats.watch)),1:par.nvids);

figure(1);clf;box on;hold all;
plot(sort(n),1-(1:length(n))/length(n));

xlabel('views k');
ylabel('P(X > k)');
set(gca,'xscale','log','yscale','log');
%set(gca,'xscale','log');
%printfig(gcf, 'views')
hold all;
plot(1:max(n),(1:max(n)).^(-1/par.alpha))
%%
figure(11);clf;box on;hold all;
[cn,bin] = histc(n,1:(max(n)+1));
plot(1:(max(n)+1),cn/sum(cn),'*');
plot(1:100,(1:100).^(-1/par.alpha-1))
ylabel('P(k)');
xlabel('views k');
set(gca,'xscale','log','yscale','log');
%%
figure(2);clf;box on;hold all;
plot(sort(stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), 'descend'))
legend({'ISP', 'UNaDa'})
xlabel('cache rank');
ylabel('hit rate');
%set(gca,'yscale','log');
figure(3);clf;box on;hold all;
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'),'.')
legend({'UNaDa'})
xlabel('cache rank');
ylabel('hit rate');
ylim([0 1]) 
%set(gca,'yscale','log');
%% ISP cache size, hitrate
figure(4);clf;box on;hold all;
plot(histc(stats.AS, 1:50)*par.cachesizeAS, stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), '.')
xlabel('cache size');
ylabel('hit rate');
%% how are requests to ISP caches distributed?
figure(5);clf;box on;hold all;
assize = histc(stats.AS, 1:50);
asaccess = stats.cache_access(stats.cache.type == 1);
plot(assize, asaccess,'.');
plot(assize, stats.cache_hit(stats.cache.type == 1),'.');
xlabel('AS size');
ylabel('cache access rate');

%% parameter study 1

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

load(['results/cdsim_' simdate1 '_csAS' num2str(par.cachesizeAS) '_csUSR' num2str(par.cachesizeUSER) cachestrat1 '.mat'])

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