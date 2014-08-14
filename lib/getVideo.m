function vid=getVideo(uid, nvids, par, t, H, wall, eventType, snm, li13, categories)

constants
    
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
        case ZIPF2
            vid=find(par.zipfcdf>rand(),1,'first')-1;
        case YTSTATS
            % George you can implement your model here
        case SNM    
            %http://www.sigcomm.org/sites/default/files/ccr/papers/2013/October/2541468-2541470.pdf
            vid = getVideoSNM(par, snm, t, eventType);
                        
            % note: don't try to model popularity cascades (observed in
            % geographically distributed user base)
        case LI13
            vid = getVideoLI13(li13, eventType, t);
        case LI13Custom
            vid = getVideoLI13Custom(li13, eventType, t);
    end
    
end
