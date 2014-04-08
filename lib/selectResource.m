function [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, strategy, params)

LOCAL = 1;
RANDOM = 2;

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
            stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
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
                stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
               end
            % else no cache hit
            end
            cid = [];
        case RANDOM
            % choose random ressource
            %TBD
    end
    
    
end

