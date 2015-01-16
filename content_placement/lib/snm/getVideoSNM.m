function vid = getVideoSNM(par, snm, time, eventType)
WATCH=1;
SHARE=2;
RESHARE=3;
CACHE=4;

if (isempty(snm.active) && ~isempty(snm.unseen))
    newOne = true;
elseif (~isempty(snm.active) && isempty(snm.unseen))
    newOne = false;
elseif (~isempty(snm.active) && ~isempty(snm.unseen))
    if par.snm.shareOnlyActive
        %inactive videos can't be shared
        if eventType == WATCH
            watchVid = true;
        else
            watchVid = false;
        end
    else
       watchVid = true; 
    end
    
    if watchVid
        %standard behaviour
        rnd = rand();
        newOne = rnd < par.snm.newVideoProb;
    else
        newOne = false;
    end

else
    error('No more active or unseen videos.')
end

if (~newOne)
    %currently active video
    % - sum up all requestProbs of all active videos
    % - draw randomly out of this pool
    % - check lifeSpan of content
    cumRequests = cumsum(snm.videoRequestProb(snm.active));

    rnd = rand() * cumRequests(length(cumRequests));

    tmpID = find(rnd <= cumRequests, 1, 'first');

    vid = snm.active(tmpID);
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