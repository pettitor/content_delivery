[n,bin] = histc(stats.share(~isnan(stats.share)),1:10000);

figure(1);clf;hold all;
plot(sort(n, 'descend'));

xlabel('video rank');
ylabel('views');
set(gca,'xscale','log','yscale','log');
%printfig(gcf, 'views')

%%
figure(2);clf;hold all;
plot(sort(stats.cachehit./stats.cacheaccess, 'descend'))
xlabel('cache rank');
ylabel('hit rate');