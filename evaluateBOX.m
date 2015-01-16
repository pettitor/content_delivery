%% total isp cache hit rate
pshare = 10.^(-5:0.5:-2);
alpha = 0.8;
cAS = 0.01;
%figure(2);clf;box on;hold all;
color = copper(3);
cASv = [0.01];
for j=1:length(cASv);
    cAS = cASv(j);
for run=1:1;
    for i=1:length(pshare); load(['results/D24_simBOX_cAS' num2str(cAS) '_alpha' num2str(alpha) '_run' num2str(run) '.mat']);
        isp(i, run) = mean(stats(i).cache_hit(1:100)./stats(i).cache_access(1:100)); end;
end
data = isp;
mittelwert = mean(data,2); % mittelwert über runs

for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
%errorbar(pshare,mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,'x-',...
%    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
plot(pshare, mittelwert,'x-',...
    'Color',color(j,:),'LineWidth', 2, 'MarkerSize', 8);
end
%%
set(gca,'xscale','log')
xlim([1e-5 1e-2])
%legend({'C_{ISP}=0.01', 'C_{ISP}=0.001','C_{ISP}=0.0001'})
xlabel('sharing probability p_{share}')
ylabel('mean ISP cache hit rate')