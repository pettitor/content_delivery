function li13 = updateLI13(video, eventType, par, li13, time, numberOfFriends)

constants;

if (eventType == WATCH)
    if (li13.v(video) == 0)
        li13.initialView(video) = time;
        li13.lastShare(video) = time;
    end
    li13.v(video) = li13.v(video) + 1;
    
    li13.ev(video) = li13.e(video) + li13.v(video);
    li13.p = li13.ev/sum(li13.ev);
elseif (eventType == UPLOAD)
    li13.p(video) = 1/par.nvids;
else
    li13.lastShare(video) = time;
    li13.e(video) = li13.e(video) + binornd(numberOfFriends, par.li13.ViR);
    
    li13.ev(video) = li13.e(video) + li13.v(video);
    li13.p = li13.ev/sum(li13.ev);
end

end