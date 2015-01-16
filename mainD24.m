
pshare = 10.^(-5:0.5:-2);
pshare = 10.^-3;

alpha = 0.8;
cachesizeAS = 0.001;

%matlabpool 7
for cachesizeAS = 0.01%[0.001 0.0001]
for run=1:1

    clear stats;
    
for i=1:length(pshare)

stats(i) = parD24(pshare(i), alpha, cachesizeAS, 13+run*7);

end

%save(['results/D24_simBOX_cAS' num2str(cachesizeAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat'], 'stats')

end
end
%matlabpool close

%% nuser
pshare = 10.^(-3:0.2:-2);

nASuser = histc([stats.AS], 1:max([stats.AS]));
figure(1);clf;box on;hold all;

for i=1:length(pshare)
    
    
    plot(1./nASuser, stats(i).cache_hit(1:100)./stats(i).cache_access(1:100),'.');
end

figure(2);clf;box on;hold all;
for i=1:length(pshare)
    plot(1./nASuser, stats(i).cache_serve(1:100)./sum(stats(i).views),'.');
end

%%
figure(444);hold all;
for run=1:1 for i=1:length(pshare)-1 load(['results/D24_sim1_alpha0.99_run' num2str(run) '.mat']); hr(i, run) = sum(stats(i).cache_serve(101:end))./1e6; end; end
plot(pshare(1:end-1), mean(hr,2),'.')
for run=1:1 for i=1:length(pshare)-1 load(['results/D24_sim1_alpha0.99_run' num2str(run) '.mat']); isp(i, run) = sum(stats(i).cache_serve(1:100))./1e6; end; end
plot(pshare(1:end-1), mean(isp,2),'.')

%% total home router contribution
pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(1);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    for i=1:length(pshare); load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        hr(i, run) = sum(stats(i).cache_serve(101:end))./1e6; end;
end
data = hr;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'d-',...
    'Color',color(j,:));
%plot(pshare, mean(hr,2),'.')
end
%% total isp cache contribution
pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(2);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    for i=1:length(pshare); load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        isp(i, run) = sum(stats(i).cache_serve(1:100))./1e6; end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'o--',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'C_{ISP}=0.01', 'C_{ISP}=0.001','C_{ISP}=0.0001'})
xlabel('sharing probability p_{share}')
ylabel('total ISP cache contribution')
%% total served locally
figure(4);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    for i=1:length(pshare); load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        hr(i, run) = sum(stats(i).cache_serve(101:end))./1e6;
        tot(i, run) = sum(stats(i).cache_serve)./1e6; end;
end
data = tot;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'s:',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
data = hr;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'d-',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'total', 'home router'})
xlabel('sharing probability p_{share}')
ylabel('total amount of requests served locally')
%% total isp cache hit rate
pshare = 10.^(-5:0.5:-2);
alpha = 0.8;
cAS = 0.01;
figure(2);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    for i=1:length(pshare); load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        isp(i, run) = mean(stats(i).cache_hit(1:100)./stats(i).cache_access(1:100)); end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'o--',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'C_{ISP}=0.01', 'C_{ISP}=0.001','C_{ISP}=0.0001'})
xlabel('sharing probability p_{share}')
ylabel('mean ISP cache hit rate')
%% total hit rate
figure(4);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
    for i=1:length(pshare);
        hr(i, run) = nanmean(stats(i).cache_hit(101,end)./stats(i).cache_access(101,end));
        tot(i, run) = nanmean(stats(i).cache_hit./stats(i).cache_access); end;
end
data = tot;
mittelwert = mean(data,2); % mittelwert über runs

cialle = nan(size(data, 1),2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'s:',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
data = hr;
mittelwert = mean(data,2); % mittelwert über runs
cialle = nan(size(data, 1),2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'d-',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'total', 'home router'})
xlabel('sharing probability p_{share}')
ylabel('total amount of requests served locally')
%% ISP cache hit rate dependent on ISP size

pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(1);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:5;
    load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
    ASsize = histc(stats(3).AS,1:100);
    [~,ind] = sort(ASsize, 'descend');
    isp(ind, run) = (stats(3).cache_hit(ind)./stats(3).cache_access(ind));
end;

data = isp;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(1:5,mittelwert(1:5),cialle(1:5,1)-mittelwert(1:5),cialle(1:5,2)-mittelwert(1:5),'o-',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(1:10,mittelwert(1:10),'d-',...
%    'Color',color(j,:));
%plot(pshare, mean(hr,2),'.')
end
%%
xlim([1 5])
legend({'C_{ISP}=0.01', 'C_{ISP}=0.001','C_{ISP}=0.0001'})
xlabel('AS rank')
ylabel('ISP cache hit rate')
%% total isp cache contribution dependent on alpha
pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(2);clf;box on;hold all;
color = copper(3);
alphav = [0.6 0.8 0.99];
for j=1:length(alphav);
    alpha = alphav(j);
    isp = nan(length(pshare), 5);
for run=1:5;
    load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
    for i=1:length(pshare);
        isp(i, run) = nansum(stats(i).cache_serve(1:100))./1e6; end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

cialle = nan(size(data,1), 2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'o--',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'alpha=0.6', 'alpha=0.8','alpha=0.99'})
xlabel('sharing probability p_{share}')
ylabel('total ISP cache contribution')
%%
%% total served locally
figure(4);clf;box on;hold all;
color = copper(3);
cASv = [0.01 0.001 0.0001];
alphav = [0.6 0.8 0.99];
for j=1:length(alphav);
    alpha = alphav(j);
    hr = nan(length(pshare), 5);
    tot = nan(length(pshare), 5);
for run=1:5;
    load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
    for i=1:length(pshare);
        hr(i, run) = sum(stats(i).cache_serve(101:end))./1e6;
        tot(i, run) = sum(stats(i).cache_serve)./1e6;
    end;
end
data = tot;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'s:',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
data = hr;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
h(j) = errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'d-',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'total', 'home router'})
xlabel('sharing probability p_{share}')
ylabel('total amount of requests served locally')
%% mean isp cache hit rate dependent on alpha
pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(2);clf;box on;hold all;
color = copper(3);
alphav = [0.6 0.8 0.99];
for j=1:length(alphav);
    alpha = alphav(j);
    isp = nan(length(pshare), 5);
for run=1:5;
    load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
    for i=1:length(pshare);
        isp(i, run) = nanmean(stats(i).cache_hit(1:100)./stats(i).cache_access(1:100)); end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

cialle = nan(size(data,1), 2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'o--',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
legend({'alpha=0.6', 'alpha=0.8','alpha=0.99'})
xlabel('sharing probability p_{share}')
ylabel('mean ISP cache hit rate')
%%
servedCombined = NaN(100,length(stats));%length(cachesizeAS));
for jj=1:length(stats);%length(cachesizeAS)
for kk=1:100
reqAS = stats(jj).AS(stats(jj).uid(~isnan(stats(jj).uid)));
nreqAS = histc(reqAS,1:100);
servedCombined(kk,jj) = stats(jj).cache_serve(1:length(stats(jj).cache.AS))'*(stats(jj).cache.AS == kk)/nreqAS(kk);
end
end

%%
color = copper(length(stats));
figure(3);clf;box on; hold all;
for jj=1:length(stats);
    plot(1:100,100*servedCombined(:,jj),'+','Color',color(jj,:),'MarkerSize',14);
end
%plot(1:size,servedCombined(:,3),'.','Color','blue','MarkerSize',14);
%plot(1:size,servedCombined(:,5),'x','Color','black','MarkerSize',14);
%title('Durch gemischtes Caching beantwortete Anfragen P(X) in %, mit der Variablen Y f�r ISP-Cache','FontSize', 24);
xlabel('AS Rank','FontSize', 24);
ylabel('Durch Caching beantwortete Anfragen P(X) in %','FontSize', 24);
%legend('+ Cachgr��e Y = 0.0001','* Cachegr��e Y = 0.001','x Cachegr��e Y = 0.01');
set(gca,'xscale','log','yscale','lin','FontSize', 24)
%% isp cache hit rate dependent on isp cache capacity
pshare = 10.^(-5:0.5:-2);
alpha = 0.99;
cAS = 0.01;
figure(2);clf;box on;hold all;
color = copper(3);
cASv = [0.0001 0.001 0.01];
AS = [1 4 8];
for j=1:length(AS);
    isp = nan(3, 5);
for run=1:5;
    for i=1:length(cASv);
        cAS = cASv(i);
        load(['results/D24_sim1_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        isp(i, run) = (stats(3).cache_hit(AS(j))./stats(3).cache_access(AS(j)));
    end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

cialle = nan(size(data,1), 2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(cASv,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'o--',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
%plot(pshare, mean(hr,2),'.')
end
%%
set(gca,'xscale','lin')
%xlim([1e-5 1e-2])
legend({'AS 1', 'AS 5','AS 10','AS 50','AS 100'})
xlabel('ISP cache capacity C_{ISP}')
ylabel('ISP cache hit rate')