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
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'))
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