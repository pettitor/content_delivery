function vid = getVideoLI13(li13, eventType, t, currentVid)

WATCH=1;
SHARE=2;
RESHARE=3;

if (eventType == WATCH)
    if (t == 0)
        probs = li13.p;
    else
        times = t-li13.lastShare;
        probs = li13.p./times;
    end
    
    cumSum = cumsum(probs);
    rnd = rand();

    idx = find(rnd <= cumSum, 1, 'first'); %find video according to p and rnd

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
        prob = li13.shr(currentVid)/timeSinceFirstView;
    end
    
    r = rand();
    if (r > prob)
        vid = currentVid;
    else
        vid = nan;
    end
end

%par.lastShare
%TODO bei view event: p/(time-lastShare) -> abfangen if (time-lastShare) == 0
%par.initialView = zeros(nvids); -> ersten view reinschreiben
%bei share event: p/(time-initialView) -> abfangen if (time-lastShare) == 0

end