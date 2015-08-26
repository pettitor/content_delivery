constants;

cachenuser = [50 100 200 Inf];
cisp = [0.001 0.01];
pcache = [0.00001 0.0001 0.001 0.01];

run = 1;
l = 1;

matlabpool 4;

for l = 2:10
for j=1:length(cisp)
    cispj = cisp(j);
    for i=1:length(cachenuser)
        cachenuseri = cachenuser(i);
        clear stats
        parfor k=1:length(pcache)
            
            stats(k) = parRBH(0.99, cispj, cachenuseri, pcache(k), RBHORSTOVERLAY, l);

        end
    %save(['results/RBHOVERLAY_ZIPF_cnuser' num2str(cachenuseri) '_cisp' num2str(cispj) '_run' num2str(l) '.mat'], 'stats')    
    end
    
end
end

for l = 1:10
for j=1:length(cisp)
    cispj = cisp(j);
    for i=1:length(cachenuser)
        cachenuseri = cachenuser(i);
        clear stats
        for k=1:length(pcache)
            
            stats(k) = parRBH(0.8, cispj, cachenuseri, pcache(k), RBHORSTOVERLAY, l);

        end
    %save(['results/RBHOVERLAY_0.8_ZIPF_cnuser' num2str(cachenuseri) '_cisp' num2str(cispj) '_run' num2str(l) '.mat'], 'stats')    
    end
    
end
end

matlabpool close;

%%

pcache = 10.^(-4.5:0.5:-1);

runs=10;

traffic = zeros(length(pcache),5,10);
ispcontrib = zeros(length(pcache),runs);
for l=1:runs
load(['results/RBHOVERLAY_ZIPF_cnuser' num2str(100) '_cisp' num2str(0.001) '_run' num2str(l) '.mat'])

    for k=1:length(pcache)

    traffic(k,:,l) = traffic(k,:,l) + hist(stats(k).traffic(~isnan(stats(k).traffic)), 0:4)/sum(~isnan(stats(k).watch));
    ispcontrib(k,l) = sum(stats(k).cache_serve(1:sum(stats(k).cache.type == 1)))/sum(~isnan(stats(k).watch));
    
    end
end
%traffic = traffic/runs;
%ispcontrib = ispcontrib/runs;

%%
figure(1);clf;bar(traffic')
%%

figure(2);hold all;
%plot(pcache, mean(ispcontrib,2))

symbols = {'-.bx',':bo','--bs','-bd'};
theta = [50, 100, 200, Inf];

for j=1:3

runs=10;

traffic = zeros(length(pcache),5);
ispcontrib = zeros(length(pcache),runs);
for l=1:runs
load(['results/RBHOVERLAY_ZIPF_cnuser' num2str(theta(j)) '_cisp' num2str(0.001) '_run' num2str(l) '.mat'])

    for k=1:length(pcache)

    traffic(k,:) = traffic(k,:) + hist(stats(k).traffic(~isnan(stats(k).traffic)), 0:4)/sum(~isnan(stats(k).watch));
    ispcontrib(k,l) = sum(stats(k).cache_serve(1:sum(stats(k).cache.type == 1)))/sum(~isnan(stats(k).watch));
    
    end
end
traffic = traffic/runs;

    
for i=1:size(ispcontrib, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(ispcontrib(i,:),mean(ispcontrib(i,:)));
    cialle(i,:) = ci;
end
errorbar(pcache,mean(ispcontrib,2),cialle(:,1)-mean(ispcontrib,2),cialle(:,1)-mean(ispcontrib,2)...
    ,'-bd','Color','black','LineWidth', 2, 'MarkerSize', 8);

figure(4);hold all;
plot(pcache, traffic(:,1)+traffic(:,2))


% = 1-(sum(stats.cache_serve))/sum(stats.views);
% = sum(stats.cache_serve(1:par.ASn))/sum(stats.views);
% = sum(stats.cache_serve(par.ASn+1:end))/sum(stats.views);

%plot(pshare, mean(hr,2),'.')
end
%%
figure(4);hold all;
%plot(pcache, traffic(:,1)+traffic(:,2))

data = squeeze(traffic(:,1,:)+traffic(:,2,:));
clear cialle
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mean(data(i,:)));
    cialle(i,:) = ci;
end
errorbar(pcache,mean(data,2),cialle(:,1)-mean(data,2),cialle(:,1)-mean(data,2)...
    ,'-bd','Color','black','LineWidth', 2, 'MarkerSize', 8);
%%

%plot(pcache, traffic(:,5))

figure(5);hold all;
%plot(pcache, traffic(:,3)+traffic(:,4))

data = squeeze(traffic(:,3,:)+traffic(:,4,:));
clear cialle
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mean(data(i,:)));
    cialle(i,:) = ci;
end
errorbar(pcache,mean(data,2),cialle(:,1)-mean(data,2),cialle(:,1)-mean(data,2)...
    ,'-bd','Color','black','LineWidth', 2, 'MarkerSize', 8);
%%
tc = squeeze(traffic(end-2,:,:));

figure(77);clf
bar(squeeze(mean(tc,2)))
%%
set(gca,'XtickLabel',{'personal','local','peering','customer','provider'})
xlabel('network       AS          AS          AS          AS    ')
%xlabel('network      ISP         ISP         ISP         ISP    ')
ylabel('share of requests served')
legend({'C_{ISP}=0.01','C_{ISP}=0.001','C_{ISP}=0'})
%% cis
hold all;
clear cialle
data = squeeze(tc(:,:,3));
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mean(data(i,:)));
    cialle(i,:) = ci;
end
%-0.22
errorbar((1:5)+0.22,mean(data,2),cialle(:,1)-mean(data,2),cialle(:,1)-mean(data,2)...
    ,'','Color','black','LineWidth', 2, 'MarkerSize', 8);
%% cis
hold all;
clear cialle
for i=1:size(tc(:,:,2), 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(tc(i,:,2),mean(tc(i,:,2)));
    cialle(i,:) = ci;
end
errorbar((1:5)+0.14,mean(tc(:,:,2),2),cialle(:,1)-mean(tc(:,:,2),2),cialle(:,1)-mean(tc(:,:,2),2)...
    ,'','Color','black','LineWidth', 2, 'MarkerSize', 8);
%%

pcache = [0.00001 0.0001 0.001 0.01];

for i=1:length(cachenuser)
    
    load(['results/RBHOVERLAY_ZIPF_cnuser' num2str(cachenuser(i)) '_cisp' num2str(0.01) '_run' num2str(l) '.mat'])

    traffic2(i,:) = hist(stats(4).traffic(~isnan(stats(4).traffic)), 0:4);
    ispcontrib2(i) = sum(stats(4).cache_serve(1:sum(stats(4).cache.type == 1)))/sum(~isnan(stats(4).watch));
    
end
figure(3);bar(traffic(:,1:4)')
%%

figure(4);clf;hold all;box on
plot(traffic2(:,1))
plot(traffic2(:,2))
plot(traffic2(:,3))
plot(traffic2(:,4))
plot(traffic2(:,5))