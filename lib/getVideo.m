function vid=getVideo(uid, nvids, par, t, id, stats, wall, eventType, categories)

constants
    
    % TODO
    % niche - popular
    % propagation size dependent on clustering coefficient ~ 150*exp(-5*x)
    % TODO recency
    switch par.demand_model
        case MEME
            score = 1*(stats.views(1:nvids)./(1+t-stats.tupload(1:nvids))).*exp(-0.00001*(t-stats.tupload(1:nvids)));
            p = score/nansum(score);
            %pind = ~isnan(p);
            %p(pind) = p(pind);% + 0.1*stats.zipfp(pind)';
            %p = p./nansum(p);
            vid = find(cumsum(p)>rand(),1,'first');
        case WALL
            ind = min(geornd(0.25), size(wall,2));
            if (ind == 0 || isnan(wall(uid,ind)))
                vid = random('unif', 1, nvids); %randi(size(GV,1));
            else
                vid = wall(uid,ind);
            end
%         case ZIPF
%             vid = nvids + 1;
%             while vid > nvids
%                 % TODO check correct value for alpha
%                 vid = randraw('zeta', par.alpha, 1);
%             end
        case ZIPF2
            vid=find(par.zipfcdf>rand(),1,'first')-1;
        case YTSTATS
            % George you can implement your model here
        case BOX
            vid = par.viewid(id);
    end
    
end
