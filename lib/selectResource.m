function [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par, iCacheUser)

LOCAL = 1;
RANDOM = 2;
RANDOM2 = 4;
RBHORST = 3;
TREE = 5;
RBHORSTOVERLAY = 6;

cid = []; % if no local cache can serve the request

    switch par.resourceselection
        case LOCAL
            personal = false(length(cache.AS),1);
            if (iCacheUser(uid))
                pid = find(find(iCacheUser) == uid,1,'first') + par.nAScache;
                %pid = uid + par.nAScache;
                personal(pid) = true;
            end
            local = cache.AS == AS(uid);
            user = (cache.type == 2);
%            items = cell2mat(cache.items);
            hit = any(cache.items == vid, 2);
            bw = (cache.occupied == 0 | cache.bw./(cache.occupied+1) >= par.BWthresh);
%             hit = false(size(cache.items,1),1);
%             parfor i=1:length(hit)
%                 hit(i) = any(cache.items{i} == vid);
%             end

%            hit = cellfun(@(x)any(x == vid), cache.items,'UniformOutput',true);
           
           access = personal;
           stats.cache_access(personal) = stats.cache_access(personal) + 1; 
           if any(hit & personal)
                stats.cache_hit(hit & personal) = stats.cache_hit(hit & personal) + 1;
                cid = find(hit & personal); %no check on bw, since no upload
           end
           if isempty(cid)
               stats.cache_access(local & user & ~personal) = stats.cache_access(local & user & ~personal) + 1;
               access = access | (local & user & ~personal);
                % choose ressource in same AS if available
               if any(local & hit & user & ~personal)

                stats.cache_hit(local & hit & user & ~personal) = stats.cache_hit(local & hit & user & ~personal) + 1;

                % pic random cache to serve
                cid = find(local & hit & user & ~personal & bw);
                if (cid)
                    cid = cid(randi(length(cid)));
                end
                %cid = cid(random('unid',1,length(cid)));
                % alternative share load on caches with hit
               end
           end
           % if not available look in isp cache
           if (isempty(cid))
               access = access | (local & ~user);
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                cid = cid(randi(length(cid)));
                %cid = cid(random('unid',1,length(cid)));

                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                end
            % else no cache hit
           end
           access = find(access);
           
        case TREE
            personal = false(length(cache.AS),1);
            if (iCacheUser(uid))
                pid = find(find(iCacheUser) == uid,1,'first') + par.nAScache;
                %pid = uid + par.nAScache;
                personal(pid) = true;
            elseif any(iCacheUser)%if no personal cache use next (random) local cache
                cuser = find(iCacheUser);
                nuid = cuser(randi(length(cuser),1));
                pid = find(find(iCacheUser) == nuid,1,'first') + par.nAScache;
                personal(pid) = true;
            end
            local = cache.AS == AS(uid);
            user = (cache.type == 2);
%            items = cell2mat(cache.items);
            hit = any(cache.items == vid, 2);
%            bw = (cache.bw./(cache.occupied+1) >= par.BWthresh);
%             hit = false(size(cache.items,1),1);
%             parfor i=1:length(hit)
%                 hit(i) = any(cache.items{i} == vid);
%             end

%            hit = cellfun(@(x)any(x == vid), cache.items,'UniformOutput',true);
           
           access = personal;
           stats.cache_access(personal) = stats.cache_access(personal) + 1; 
           if any(hit & personal)
                stats.cache_hit(hit & personal) = stats.cache_hit(hit & personal) + 1;
                cid = find(hit & personal); %no check on bw, since no upload
           end
           % if not available look in isp cache
           if (isempty(cid))
               access = access | (local & ~user);
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                cid = cid(randi(length(cid)));
                %cid = cid(random('unid',1,length(cid)));

                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                end
            % else no cache hit
           end
           access = find(access);
            
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

            access = union(find(local & ~user), par.nAScache + uid);
                        
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
            personal = false(length(cache.AS),1);
            if (iCacheUser(uid))
                pid = find(find(iCacheUser) == uid,1,'first') + par.nAScache;
                %pid = uid + par.nAScache;
                personal(pid) = true;
            end
            local = cache.AS == AS(uid);
            user = (cache.type == 2);
%            items = cell2mat(cache.items);
            hit = any(cache.items == vid, 2);
            bw = (cache.bw./(cache.occupied+1) >= par.BWthresh);
%             hit = false(size(cache.items,1),1);
%             parfor i=1:length(hit)
%                 hit(i) = any(cache.items{i} == vid);
%             end

%            hit = cellfun(@(x)any(x == vid), cache.items,'UniformOutput',true);
           
           access = personal;
           stats.cache_access(personal) = stats.cache_access(personal) + 1; 
           if any(hit & personal)
                stats.cache_hit(hit & personal) = stats.cache_hit(hit & personal) + 1;
                cid = find(hit & personal); %no check on bw, since no upload
           end
           if isempty(cid)
               stats.cache_access(local & user & ~personal) = stats.cache_access(local & user & ~personal) + 1;
               access = access | (local & user & ~personal);
                % choose ressource in same AS if available
               if any(local & hit & user & ~personal)

                stats.cache_hit(local & hit & user & ~personal) = stats.cache_hit(local & hit & user & ~personal) + 1;

                % pic random cache to serve
                cid = find(local & hit & user & ~personal & bw);
                if (cid)
                    cid = cid(randi(length(cid)));
                end
                %cid = cid(random('unid',1,length(cid)));
                % alternative share load on caches with hit
               end
           end
           % if not available look in isp cache
           if (isempty(cid))
               access = access | (local & ~user);
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                cid = cid(randi(length(cid)));
                %cid = cid(random('unid',1,length(cid)));

                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                end
            % else no cache hit
           end
           % if not available look in peering or customer AS
           if (isempty(cid))
                %get peering ASes
                peers = find(par.peer(AS(uid),:));
                %get UNaDas in peering ASes
                if any(peers)
                    peer = ismember(cache.AS, peers);
                    access = access | (peer & user);
                    stats.cache_access(peer & user) = stats.cache_access(peer & user) + 1;
                    if any(peer & hit & user)
                        cid = find(peer & hit & user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
                    if (isempty(cid))
                        access = access | (peer & ~user);
                        stats.cache_access(peer & ~user) = stats.cache_access(peer & ~user) + 1;
                        if any(peer & hit & ~user)
                            cid = find(peer & hit & ~user);
                            cid = cid(randi(length(cid)));
                            %cid = cid(random('unid',1,length(cid)));

                            stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                        end
                    end
                end
           end
           if (isempty(cid))
                %get customer ASes
                customers = find(par.customer(AS(uid),:));
                %get UNaDas in peering ASes
                if any(customers)
                    customer = ismember(cache.AS, customers);
                    access = access | (customer & user);
                    stats.cache_access(customer & user) = stats.cache_access(customer & user) + 1;
                    if any(customer & hit & user)
                        cid = find(customer & hit & user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
                    if (isempty(cid))
                        access = access | (customer & ~user);
                        stats.cache_access(customer & ~user) = stats.cache_access(customer & ~user) + 1;
                        if any(customer & hit & ~user)
                            cid = find(customer & hit & ~user);
                            cid = cid(randi(length(cid)));
                            %cid = cid(random('unid',1,length(cid)));

                            stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                        end
                    end
                end
           end
           access = find(access);
       case RBHORSTOVERLAY
            personal = false(length(cache.AS),1);
            if (iCacheUser(uid))
                pid = find(find(iCacheUser) == uid,1,'first') + par.nAScache;
                %pid = uid + par.nAScache;
                personal(pid) = true;
            end
            local = cache.AS == AS(uid);
            user = (cache.type == 2);
%            items = cell2mat(cache.items);
            hit = any(cache.items == vid, 2);
            bw = (cache.bw./(cache.occupied+1) >= par.BWthresh);
%             hit = false(size(cache.items,1),1);
%             parfor i=1:length(hit)
%                 hit(i) = any(cache.items{i} == vid);
%             end

%            hit = cellfun(@(x)any(x == vid), cache.items,'UniformOutput',true);
           
           access = personal;
           stats.cache_access(personal) = stats.cache_access(personal) + 1; 
           if any(hit & personal)
                stats.cache_hit(hit & personal) = stats.cache_hit(hit & personal) + 1;
                cid = find(hit & personal); %no check on bw, since no upload
           end
           if isempty(cid)
               stats.cache_access(local & user & ~personal) = stats.cache_access(local & user & ~personal) + 1;
               access = access | (local & user & ~personal);
                % choose ressource in same AS if available
               if any(local & hit & user & ~personal)

                stats.cache_hit(local & hit & user & ~personal) = stats.cache_hit(local & hit & user & ~personal) + 1;

                % pick random cache to serve
                cid = find(local & hit & user & ~personal & bw);
                if (cid)
                    cid = cid(randi(length(cid)));
                end
                %cid = cid(random('unid',1,length(cid)));
                % alternative share load on caches with hit
               end
           end
           % if not available look in peering or customer AS
           %get peering ASes
           peers = find(par.peer(AS(uid),:));
           if (isempty(cid))
                %get UNaDas in peering ASes
                if any(peers)
                    peer = ismember(cache.AS, peers);
                    access = access | (peer & user);
                    stats.cache_access(peer & user) = stats.cache_access(peer & user) + 1;
                    if any(peer & hit & user)
                        cid = find(peer & hit & user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
                end
           end
           %get customer ASes
           customers = find(par.customer(AS(uid),:));
           if (isempty(cid))
                %get UNaDas in customer ASes
                if any(customers)
                    customer = ismember(cache.AS, customers);
                    access = access | (customer & user);
                    stats.cache_access(customer & user) = stats.cache_access(customer & user) + 1;
                    if any(customer & hit & user)
                        cid = find(customer & hit & user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
                end
           end
           % if not available look in isp cache
           if (isempty(cid))
               access = access | (local & ~user);
               stats.cache_access(local & ~user) = stats.cache_access(local & ~user) + 1;
               if any(local & hit & ~user)
                cid = find(local & hit & ~user);
                cid = cid(randi(length(cid)));
                %cid = cid(random('unid',1,length(cid)));

                stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                end
            % else no cache hit
           end
           if (isempty(cid))
               if any(peers)
                    peer = ismember(cache.AS, peers);
                    access = access | (peer & ~user);
                    stats.cache_access(peer & ~user) = stats.cache_access(peer & ~user) + 1;
                    if any(peer & hit & ~user)
                        cid = find(peer & hit & ~user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
               end
           end
           if (isempty(cid))
               if any(customers)
                    customer = ismember(cache.AS, customers);
                    access = access | (customer & ~user);
                    stats.cache_access(customer & ~user) = stats.cache_access(customer & ~user) + 1;
                    if any(customer & hit & ~user)
                        cid = find(customer & hit & ~user);
                        cid = cid(randi(length(cid)));
                        %cid = cid(random('unid',1,length(cid)));

                        stats.cache_hit(cid) = stats.cache_hit(cid) + 1;
                    end
               end
            end
           access = find(access);
        case PRIO
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
                    %cid = potcaches(random('unid',length(potcaches)));
                    cid = potcaches(randi(length(potcaches)));
                    break;
                end
            end
                                 
            access = union(find(local & ~user), cid);
            access = union(access, par.nAScache + uid);
            
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

