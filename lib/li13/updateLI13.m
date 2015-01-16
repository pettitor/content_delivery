function li13 = updateLI13(video, eventType, par, li13, time, numberOfFriends)

constants;

if (eventType == WATCH)
    if (video > length(li13.v)) %do initialization of values if more than par.nvids are simulated
       li13.v(video) = 0;
       li13.e(video) = 1;
       li13.ev(video) = 1;
       li13.p(video) = 1/par.nvids;
       li13.shr(video) = sum(exprnd(par.li13.SHRm/par.li13.SHRk,par.li13.SHRk,1));
    end
    if (li13.v(video) == 0)
        li13.initialView(video) = time;
        li13.lastShare(video) = time;
    end
    li13.v(video) = li13.v(video) + 1;
    
    li13.ev(video) = li13.e(video) + li13.v(video);
    
    if (li13.probabilityEquality)
        ev1 = log(li13.ev);
    
        li13.p = ev1/sum(ev1);
    else
        li13.p = li13.ev/sum(li13.ev);
    end
elseif (eventType == UPLOAD)
    li13.p(video) = 1/par.nvids;
else %SHARE
    li13.lastShare(video) = time;
    li13.e(video) = li13.e(video) + binornd(numberOfFriends, par.li13.ViR);
    
    li13.ev(video) = li13.e(video) + li13.v(video);
    li13.p = li13.ev/sum(li13.ev);
end

end