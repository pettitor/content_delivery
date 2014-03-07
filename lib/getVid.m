function vid=getVid(uid, GV, H, wall)
    % TODO
    % niche - popular
    % propagation size dependent on clustering coefficient ~ 150*exp(-5*x)
    % TODO recency
    ind = min(geornd(0.4)+1, size(wall,2));
    if (isnan(wall(uid,ind)))
        vid = random('unif', 1, size(GV,1)); %randi(size(GV,1));
    else
        vid = wall(uid,ind);
    end
end