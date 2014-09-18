par.nvids = 100;
par.nrequests = 1000;

par.alpha = 0.99;

a=exp(-par.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
par.zipfcdf = zipfcdf/zipfcdf(end);

par.tmax = 1e4;

% anzahl requests auswürfeln 
vid = nan(1,par.nrequests);
for i=1:length(vid)
    vid(i) = find(par.zipfcdf>rand(),1,'first')-1;
end
[nrequests,bin] = histc(vid,1:par.nvids);
nrequests = nrequests(randperm(par.nvids));

% lifespan auswürfeln
m = par.tmax/10; % hier brauchen wir noch realistische werte, optimal wäre abhängig von views
v = par.tmax;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
tau = lognrnd(mu, sigma, 1, par.nvids);

% importzeitpunkt auswürfeln
vidimport = cumsum(exprnd(par.tmax/par.nvids, 1, par.nvids));

viewt = [];
viewid = [];
for i=1:length(nrequests)
viewt = [viewt vidimport(i)+cumsum(exprnd(tau(i)/nrequests(i), 1, nrequests(i)))];
viewid = [viewid i*ones(1,nrequests(i))];
end

[viewt, idx] = sort(viewt);
viewid = viewid(idx);
