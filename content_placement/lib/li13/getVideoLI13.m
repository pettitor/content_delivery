function vid = getVideoLI13(li13, eventType, t, currentVid)

WATCH=1;
SHARE=2;
RESHARE=3;

if (eventType == WATCH)
    if (t == 0)
        probs = li13.p;
    else
        if (li13.viewAttenuation)
            times = t-li13.lastShare;
            probs = li13.p.*exp(-li13.tmpAttenuationExp*times);
        else
            probs = li13.p;
        end
        %probs decrease the farther away the last share was
    end
    
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
    timeSinceFirstView = t-li13.initialView(currentVid);
    if (timeSinceFirstView == 0)
        prob = li13.shr(currentVid);
    else
        if (li13.shareAttenuation)
           prob = li13.shr(currentVid)*exp(-li13.tmpAttenuationExp*timeSinceFirstView);
        else
           prob = li13.shr(currentVid);
        end
    end
    
    r = rand();
    if (r > prob)
        vid = currentVid;
    else
        vid = nan;
    end
end