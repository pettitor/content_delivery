[n,bin] = histc(stats.vid(~isnan(stats.vid)),1:par.nvids);

figure(1);clf;box on;hold all;
plot(sort(n, 'descend'));

xlabel('video rank');
ylabel('views');
set(gca,'xscale','log','yscale','log');
%printfig(gcf, 'views')

%%
figure(2);clf;box on;hold all;
plot(sort(stats.cache_hit(stats.cache.type == 1)./stats.cache_access(stats.cache.type == 1), 'descend'))
plot(sort(stats.cache_hit(stats.cache.type == 2)./stats.cache_access(stats.cache.type == 2), 'descend'))
legend({'ISP', 'UNaDa'})
xlabel('cache rank');
ylabel('hit rate');
set(gca,'xscale','log','yscale','log');