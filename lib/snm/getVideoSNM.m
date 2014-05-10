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
%snm.unseen
%snm.endOfLife(videoID) = timeStamp (t+lifeSpan)

rnd = rand();
newOne = true;

if (isempty(snm.active) && ~isempty(snm.unseen))
    newOne = true;
elseif (~isempty(snm.active) && isempty(snm.unseen))
    newOne = false;
elseif (~isempty(snm.active) && ~isempty(snm.unseen))
    newOne = rnd < par.snm.newVideoProb;
else
    error('No more active or unseen videos.')
end

if (~newOne)
    %currently active video
    % - sum up all requestProbs of all active videos
    % - draw randomly out of this pool
    % - check lifeSpan of content
    cumRequests = cumsum(snm.videoRequestProb(snm.active));
    
    fit = false;

    while ~fit
        rnd = rand() * cumRequests(length(cumRequests));
    
        tmpID = find(rnd <= cumRequests, 1, 'first');

        vid = snm.active(tmpID);
        
        fit = snm.endOfLife(vid) <= time;
    end
else
    %unseen video
    % - sum up all requestProbs of all active videos
    % - draw randomly out of this pool
    cumRequests = cumsum(snm.videoRequestProb(snm.unseen));
    
    rnd = rand() * cumRequests(length(cumRequests));
    
    tmpID = find(rnd <= cumRequests, 1, 'first');

    vid = snm.unseen(tmpID);
end

end