function box = prepareBoxModel(par)

a=exp(-par.box.alpha .* log(1:par.nvids));
zipfcdf = cumsum([0 a]);
box.zipfcdf = zipfcdf/zipfcdf(end);

% anzahl requests auswürfeln 
vid = nan(1,par.box.nrequests);
for i=1:length(vid)
    vid(i) = find(box.zipfcdf>rand(),1,'first')-1;
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

box.viewt = [];
box.viewid = [];
for i=1:length(nrequests)
    box.viewt = [box.viewt vidimport(i)+cumsum(exprnd(tau(i)/nrequests(i), 1, nrequests(i)))];
    box.viewid = [box.viewid i*ones(1,nrequests(i))];
end

[box.viewt, idx] = sort(box.viewt);
box.viewid = box.viewid(idx);
box.idx = 1;

end

