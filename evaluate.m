[n,bin] = histc(stats.share(~isnan(stats.share)),1:10000);

plot(sort(n, 'descend'));

xlabel('video rank');
ylabel('views');

printfig(gcf, 'views')