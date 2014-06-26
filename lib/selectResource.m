function [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, strategy, par)

LOCAL = 1;
RANDOM = 2;
RANDOM2 = 4;
RBHORST = 3;

cid = []; % if no local cache can serve the request
access = [];

    switch strategy
        case LOCAL
            local = cache.AS == AS(uid);
            user = cache.type == 2;
%            items = cell2mat(cache.items);
            hit = any(cache.items == vid, 2);
%             hit = false(size(cache.items,1),1);
%             parfor i=1:length(hit)
%                 hit(i) = any(cache.items{i} == vid);
%             end

%            hit = cellfun(@(x)any(x == vid), cache.items,'UniformOutput',true);
            
           stats.cache_access(local & user) = stats.cache_access(local & user) + 1;
           access = find(local & user);
            % choose ressource in same AS if available
           if any(local & hit & user)
               
            stats.cache_hit(local & hit & user) = stats.cache_hit(local & hit & user) + 1;
            
            % pic random cache to serve
            cid = find(local & hit & user);
            %cid = cid(randi(length(cid)));
            cid = cid(random('unid',1,length(cid)));
            % alternative share load on caches with hit
            
            % if not available look in isp cache
           else
               access = union(access, find(local & ~user));
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                %cid = cid(randi(length(cid)));
                cid = cid(random('unid',1,length(cid)));
            
                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                end
            % else no cache hit
            end
            
        case RANDOM
            % choose random resource
            cid = random('unid',length(cache.AS));
            stats.cache_access(cid) = stats.cache_access(cid) + 1;
            stats.AS_access(AS(uid)) = stats.AS_access(AS(uid)) + 1;
            access = cid;
            % if hit
            if any(cache.items(cid,:) == vid)
                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                if (cache.AS(cid) == AS(uid))
                    stats.AS_hit(AS(uid)) = stats.AS_hit(AS(uid)) + 1;
                end
            % else download from dc
            else
                
            end
        case RANDOM2
            % choose random resource
            local = cache.AS == AS(uid);
            user = cache.type == 2;
            hit = any(cache.items == vid, 2);

            access = union(find(local & ~user), par.ASn + uid);
                        
            if (any(hit))
            cids = find(hit);
            cid = cids(random('unid',length(cids)));
           
            access = union(access, cid);
         
            stats.cache_access(cid) = stats.cache_access(cid) + 1;
            stats.AS_access(AS(uid)) = stats.AS_access(AS(uid)) + 1;
            % if hit
                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                if (cache.AS(cid) == AS(uid))
                    stats.AS_hit(AS(uid)) = stats.AS_hit(AS(uid)) + 1;
                end
            % else download from dc
            else
                
            end
        case RBHORST
            % RBHORST tracks cached items in DHT
            % assume RBHORST provides list with caches that store item
            % list can be sorted to optimize
            % a) ISP cache contribution (prioritize UNaDa in different AS over ISPcache)
            % b) inter-domain traffic (prioritize ISPcache over UNaDa in different AS)
            %
            % at the moment: one of equally prioritized UNaDas is selected randomly

            local = cache.AS == AS(uid);
            user = cache.type == 2;
            hit = any(cache.items == vid, 2);
            
            prio = zeros(1, length(cache.capacity));
            if (par.RBHORSTprio == 1) % prio UNaDa and update ISP cache only if not available in AS
                prio(hit & local & user) = 1;
                prio(hit & ~local & user) = 2;
                prio(hit & local & ~user) = 3;
                prio(hit & ~local & ~user) = 4;
            elseif (par.RBHORSTprio == 2) %prio ISPcache
                prio(hit & local & ~user) = 1;
                prio(hit & local & user) = 2;
                prio(hit & ~local & ~user) = 3;
                prio(hit & ~local & user) = 4;
            elseif (par.RBHORSTprio == 3) %prio AS
                prio(hit & local & user) = 1;
                prio(hit & local & ~user) = 2;
                prio(hit & ~local & user) = 3;
                prio(hit & ~local & ~user) = 4;
            end
            
            %stats.AS_access(local) = stats.AS_access(local) + 1;
            
            for p=1:4
                potcaches = find(prio==p);
                if (~isempty(potcaches))
                    cid = potcaches(random('unid',length(potcaches)));
                    break;
                end
            end
                                 
            access = union(find(local & ~user), cid);
            access = union(access, par.ASn + uid);
            
            stats.AS_access(AS(uid)) = stats.AS_access(AS(uid)) + 1;
            if (cache.AS(cid) == AS(uid))
                stats.AS_hit(AS(uid)) = stats.AS_hit(AS(uid)) + 1;
            end
            
            if (cid)
                stats.cache_access(cid) = stats.cache_access(cid) + 1;
                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
            else
            % else no cache hit
            %TODO record in stats
            end
    end
    
    
end

