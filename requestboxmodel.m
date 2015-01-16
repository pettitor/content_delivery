par.nvids = 100;
par.nrequests = 1000;

par.alpha = 0.99;

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

par.twarmup = 1e3;
par.tmax = par.twarmup + 1e4;

% anzahl requests auswürfeln 
vid = nan(1,par.nrequests);
for i=1:length(vid)
    vid(i) = find(par.zipfcdf>rand(),1,'first')-1;
end
[nrequests,bin] = histc(vid,1:par.nvids);
nrequests = nrequests(randperm(par.nvids));

% lifespan auswürfeln
m = par.tmax/10;
v = par.tmax;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
tau = lognrnd(mu, sigma, 1, par.nvids);

% importzeitpunkt auswürfeln
% TODO import frequenz
vidimport = cumsum(exprnd(par.tmax/par.nvids, 1, par.nvids));

viewt = [];
viewid = [];
for i=1:length(nrequests)
viewt = [viewt vidimport(i)+cumsum(exprnd(tau(i)/nrequests(i), 1, nrequests(i)))];
viewid = [viewid i*ones(1,nrequests(i))];
end

[viewt, idx] = sort(viewt);
viewid = viewid(idx)
%% temporal locality
figure(2); clf; box on;

hold all;

[n,bin] = histc(viewid,1:par.nvids);

[nviews, vid] = sort(n,'descend');

dt = par.tmax/100;
t = 1:dt:par.tmax;
views = zeros(5,length(t));

for i=1:par.nvids

[n,bin] = histc(viewt(viewid == vid(i)),t);

views(i,:) = n;

end

%bar(t,views')
%plot(t,views')
plot(t,sum(views))

xlabel('views k');
ylabel('P(X > k)');
%set(gca,'xscale','log','yscale','log');
%set(gca,'xscale','log');
%printfig(gcf, 'views')
%%
figure(1);clf;loglog(nviews)