function snm=prepareSNM(par)
%par.snm.newVideoProb
%par.snm.classes.perc
%par.snm.classes.lifeSpan
%par.snm.classes.requests
%par.nvids

maxVal = sum(par.snm.classes.perc);
cumSum = cumsum(par.snm.classes.perc);

snm.videos = NaN(par.nvids,1);
snm.seen = [];
snm.timeStamps = zeros(par.nvids,1);

for i=1:par.nvids
    rnd = rand() * maxVal;
    
    snm.videos(i) = find(rnd <= cumSum, 1, 'first'); %find the category for random number
end

%TODO object:
%snm.vids = videoID -> Class
%snm.seen = [videoID] -> snm.vids[snm.seen] -> array mit nur gesehen
%snm.timeStamp = videoID -> timeStamp (initialWatched)
end