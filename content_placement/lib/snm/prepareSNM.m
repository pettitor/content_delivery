function snm=prepareSNM(par)
%par.snm.newVideoProb
%par.snm.classes.perc
%par.snm.classes.lifeSpan
%par.snm.classes.requests
%par.nvids

percSum = cumsum(par.snm.classes.perc);

snm.videoClass = NaN(par.nvids,1);
snm.videoLifeSpan = NaN(par.nvids,1);
snm.videoRequestProb = NaN(par.nvids,1);
snm.active = [];
snm.unseen = 1:1:par.nvids;
snm.endOfLife = zeros(par.nvids,1);

for i=1:par.nvids
    rnd = rand() * percSum(length(percSum));
    
    class = find(rnd <= percSum, 1, 'first');
    snm.videoClass(i) = class;
    
    %TODO randomize around par.snm.classes value
    snm.videoLifeSpan(i) = par.snm.classes.lifeSpan(class);
    snm.videoRequestProb(i) = par.snm.classes.requests(class);
end

%snm.videoClass(videoID) = class
%snm.videoLifeSpan(videoID) = lifeSpan
%snm.videoRequestProb(videoID) = Request probability
%snm.active = [videoID] -> snm.videoClass(snm.active) -> aktuell aktive
%snm.endOfLife(videoID) = timeStamp (t+lifeSpan)
end