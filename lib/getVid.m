function vid=getVid(uid, nvids, par, H, wall)

ZIPF = 1;
WALL = 2;
YTSTATS = 3;

    % TODO
    % niche - popular
    % propagation size dependent on clustering coefficient ~ 150*exp(-5*x)
    % TODO recency
    switch par.demand_model
        case WALL
            ind = min(geornd(0.25), size(wall,2));
            if (ind == 0 || isnan(wall(uid,ind)))
                vid = random('unif', 1, nvids); %randi(size(GV,1));
            else
                vid = wall(uid,ind);
            end
        case ZIPF
            vid = nvids + 1;
            while vid > nvids
                % TODO check correct value for alpha
                vid = randraw('zeta', par.alpha, 1);
            end
        case YTSTATS
            % George you can implement your model here
    end
    
end