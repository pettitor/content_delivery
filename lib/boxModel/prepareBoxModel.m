function box = prepareBoxModel(par)

constants

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
lifespan = nan(1,par.nvids);
switch par.box.lifeSpanMode
    case proofOfConcept
        lifespan = lognrnd(par.box.lifespan.mu, par.box.lifespan.sigma, 1, par.nvids);
    case SNM_Like
        percCumSum = cumsum(par.box.lifespan.percentage);
        percSum = sum(par.box.lifespan.percentage);
        
        for i=1:length(lifespan)
            rnd = rand() * percSum;
            idx = find(rnd <= percCumSum, 1, 'first');
            lower = par.box.lifespan.lifespan(idx,1);
            upper = par.box.lifespan.lifespan(idx,2);
            
            lifespan(i) = lower+rand()*(upper-lower);
        end
        lifespan = lifespan*par.ticksPerDay;
end

% importzeitpunkt auswürfeln
vidimport = cumsum(exprnd(par.tmax/par.nvids, 1, par.nvids));

box.viewt = [];
box.viewid = [];
for i=1:length(nrequests)
    box.viewt = [box.viewt vidimport(i)+cumsum(exprnd(lifespan(i)/nrequests(i), 1, nrequests(i)))];
    box.viewid = [box.viewid i*ones(1,nrequests(i))];
end

[box.viewt, idx] = sort(box.viewt);
box.viewid = box.viewid(idx);
box.idx = 1;

end

