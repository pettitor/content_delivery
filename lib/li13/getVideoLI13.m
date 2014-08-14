function vid = getVideoLI13(li13, eventType, t, currentVid)

WATCH=1;
SHARE=2;
RESHARE=3;

if (eventType == WATCH)
    probs = li13.p;
    
    cumSum = cumsum(probs);
    rnd = rand() * sum(probs);
    %make sure that rand() goes to the limit of the probs array

    idx = find(rnd <= cumSum, 1, 'first');
    %find video according to p and rnd
    
    if (~isempty(idx))
        vid = idx;
    else
        vid = randi(length(probs));
    end
else
    prob = li13.shr(currentVid);
    
    r = rand();
    if (r > prob)
        vid = currentVid;
    else
        vid = nan;
    end
end