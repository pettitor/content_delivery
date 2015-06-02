constants;

cachenuser = [50 100 200 Inf];
cisp = [0.001 0.01];
pcache = 10.^(-4.5:0.5:-1);

run = 1;
l = 1;

matlabpool 4;

for l = 1:10
for j=1:length(cisp)
    cispj = cisp(j);
    for i=1:length(cachenuser)
        cachenuseri = cachenuser(i);
        clear stats
        parfor k=1:length(pcache)
            
            stats(k) = parRBH(0.99, cispj, cachenuseri, pcache(k), RBHORSTOVERLAY, l);

        end
    save(['results/RBHOVERLAY_ZIPF_cnuser' num2str(cachenuseri) '_cisp' num2str(cispj) '_run' num2str(l) '.mat'], 'stats')    
    end
    
end
end

for l = 1:10
for j=1:length(cisp)
    cispj = cisp(j);
    for i=1:length(cachenuser)
        cachenuseri = cachenuser(i);
        clear stats
        parfor k=1:length(pcache)
            
            stats(k) = parRBH(0.8, cispj, cachenuseri, pcache(k), RBHORSTOVERLAY, l);

        end
    save(['results/RBHOVERLAY_0.8_ZIPF_cnuser' num2str(cachenuseri) '_cisp' num2str(cispj) '_run' num2str(l) '.mat'], 'stats')    
    end
    
end
end

matlabpool close;

%%

pcache = 10.^(-4.5:0.5:-1);

load(['results/RBHOVERLAY_ZIPF_cnuser' num2str(100) '_cisp' num2str(0.01) '_run' num2str(l) '.mat'])

for l = 1:10
for k=1:length(pcache)

    traffic(k,:) = hist(stats(k).traffic(~isnan(stats(k).traffic)), 0:4)/sum(~isnan(stats(k).watch));
    ispcontrib(k) = sum(stats(k).cache_serve(1:sum(stats(k).cache.type == 1)))/sum(~isnan(stats(k).watch));
    
end
end
%%
figure(1);clf;bar(traffic')
%%

figure(2);hold all;
plot(pcache,ispcontrib)

%%

pcache = [0.00001 0.0001 0.001 0.01];

for i=1:length(cachenuser)
    
    load(['results/RBHOVERLAY_ZIPF_cnuser' num2str(cachenuser(i)) '_cisp' num2str(0.01) '_run' num2str(l) '.mat'])

    traffic2(i,:) = hist(stats(4).traffic(~isnan(stats(4).traffic)), 0:4);
    ispcontrib2(i) = sum(stats(4).cache_serve(1:sum(stats(4).cache.type == 1)))/sum(~isnan(stats(4).watch));
    
end
figure(3);bar(traffic(:,1:4)'/)
%%

figure(4);clf;hold all;box on
plot(traffic2(:,1))
plot(traffic2(:,2))
plot(traffic2(:,3))
plot(traffic2(:,4))
plot(traffic2(:,5))