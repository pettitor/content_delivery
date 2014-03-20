function [cid, cache, stats] = selectRessource(cache, stats, AS, uid, vid, strategy, params)

cid = -1; % if no local cache can serve the request

    switch lower(strategy)
        case {'local'}
            local = cache.AS == AS(uid);
            user = cache.type == 2;
            hit = any(cache.items == vid, 2);
            
            stats.cache_access(local & user) = stats.cache_access(local & user) + 1;
           
            % choose ressource in same AS if available
           if any(local & hit & user)
               
            stats.cache_hit(local & hit & user) = stats.cache_hit(local & hit & user) + 1;
            
            % pic random cache to serve
            cid = find(local & hit & user);
            %cid = cid(randi(length(cid)));
            cid = cid(random('unid',1,length(cid)));
            stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
            % alternative share load on caches with hit
            
            % if not available look in isp cache
           else
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                %cid = cid(randi(length(cid)));
                cid = cid(random('unid',1,length(cid)));
            
                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
               end
            % else no cache hit
            end
            cid = -1;
        case {'random'}
            % choose random ressource
            %TBD
    end
    
    
end

