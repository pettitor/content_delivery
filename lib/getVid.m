function vid=getVid(uid, GV, H, wall)
    % TODO
    % niche - popular
    % propagation size dependent on clustering coefficient ~ 150*exp(-5*x)
    % TODO recency
    ind = geornd(0.4)+1;
    if (isnan(wall(ind,uid)))
        vid = randi(size(GV,1));
    else
        vid = wall(ind,uid);
    end
end