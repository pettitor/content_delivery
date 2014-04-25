function vid = getVideoSNM(par, snm, time)
%par.snm.newVideoProb
%par.snm.classes.perc
%par.snm.classes.lifeSpan
%par.snm.classes.requests
%par.nvids
%snm.videoClass(videoID) = class
%snm.videoLifeSpan(videoID) = lifeSpan
%snm.videoRequestProb(videoID) = Request probability
%snm.active = [videoID] -> snm.videoClass(snm.active) -> aktuell aktive
%snm.endOfLife(videoID) = timeStamp (t+lifeSpan)

rnd = rand();
if (rnd > par.snm.newVideoProb && ~isempty(snm.active))
    %currently active video
    % - sum up all requestProbs of all active videos
    % - draw randomly out of this pool
    % - check lifeSpan of content
    cumRequests = cumsum(snm.videoRequestProb(snm.active));
    
    rnd = rand() * cumRequests(length(cumRequests));
    
    %TODO problem: how to get the idx of the video (not from the active only list!)
    vidID = find(rnd <= cumRequests, 1, 'first');
    
    
else
    %unseen video
    % - sum up all requestProbs of all active videos
    % - draw randomly out of this pool
    % - set snm.endOfLife to t+snm.videoLifeSpan
    
end

end