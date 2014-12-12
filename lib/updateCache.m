function cache = updateCache(cache, stats, t, ids, vid, par)

% possible ideas to improve performance: sort cache.items? parfor cellarray
% accumarray?

constants;

for ii=1:length(ids) %TODO go through ids in random order!!! (c.f. LRUAS)
    id = ids(ii);
    if (cache.capacity(id) > 0)
    switch par.cachingstrategy(cache.type(id))
        case LRU

            i = cache.items(id,:) == vid;
            if any(i)
                cache.score(id,i) = t;
            else
                [~, last] = find(cache.items(id,:),1,'last');
                if isempty(last); last = 0; end
                repl = last + 1;
                if (repl > cache.capacity(id));
                    [~, repl] = min(cache.score(id,:));
                end
                cache.items(id,repl) = vid;
                cache.score(id,repl) = t;
            end
            
            
            
%             if cache.items(id,1) ~= vid
%                 i = cache.items(id,:) == vid;
%                 if any(i)
%                     cache.items(id,2:cache.capacity(id)) = cache.items(id,~i(1:cache.capacity(id)));
%                     cache.items(id,1) = vid;
%                 else
%                     cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
%                     cache.items(id,1) = vid;
%                 end
%             end
       case LS

            i = cache.items(id,:) == vid;
            if any(i)
                %cache.score(id,i) = sum(stats.numOfFriends(stats.share==vid));
                cache.score(id,i) = stats.expViews(vid);
            else
                [~, last] = find(cache.items(id,:),1,'last');
                if isempty(last); last = 0; end
                repl = last + 1;
                if (repl > cache.capacity(id));
                    [~, repl] = min(cache.score(id,:));
                end
                cache.items(id,repl) = vid;
                %cache.score(id,repl) = sum(stats.numOfFriends(stats.share==vid));
                cache.score(id,repl) = stats.expViews(vid);
            end
       case LSLRU

            i = cache.items(id,:) == vid;
            if any(i)
                cache.score(id,i) = stats.expViews(vid);
                cache.score2(id,i) = t;
            else
                [~, last] = find(cache.items(id,:),1,'last');
                if isempty(last); last = 0; end
                repl = last + 1;
                if (repl > cache.capacity(id));
                    [res, repl] = min(cache.score(id,:));
                    if (res == stats.expViews(vid))
                        tmp = cache.score2(id,:);
                        tmp(stats.expViews ~= stats.expViews(vid)) = NaN;
                        [~, repl] = min(tmp);
                    end
                end
                cache.items(id,repl) = vid;
                cache.score(id,repl) = stats.expViews(vid);
                cache.score2(id,repl) = t;
            end
            
        case LRUAS
            % cache to optimize availability in AS
            i = cache.items(id,:) == vid;
            if any(i)
                cache.score(id,i) = t;
            else
                local = cache.AS == cache.AS(id);
                user = cache.type == 2;
                hit = any(cache.items == vid, 2);
                hitlocal = local & user & hit;
                % cache, if less than par.maxitemsAS are local
                if sum(hitlocal) < par.maxitemsAS
                    [~, last] = find(cache.items(id,:),1,'last');
                    if isempty(last); last = 0; end
                    repl = last + 1;
                    if (repl > cache.capacity(id));
                        [~, repl] = min(cache.score(id,:));
                    end
                    cache.items(id,repl) = vid;
                    cache.score(id,repl) = t;
                end
            end
            
            %TODO optimize
%             if cache.items(id,1) ~= vid
%                 %if in this cache put on first position
%                 i = cache.items(id,:) == vid;
%                 if any(i)
%                     cache.items(id,2:cache.capacity(id)) = cache.items(id,~i(1:cache.capacity(id)));
%                     cache.items(id,1) = vid;
%                 %if not replace only if not available in AS
%                 else
%                     %determine UNada caches in same AS
%                     local = cache.AS == cache.AS(id);
%                     user = cache.type == 2;
%                     hit = any(cache.items == vid, 2);
%                     if ~any(local & user & hit)
%                     cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
%                     cache.items(id,1) = vid;
%                     end
%                 end
%             end
            
        case LRUSG % score gated
            ranking
            
            i = cache.items(id,:) == vid;
            if any(i) && cache.items(id,1) ~= vid
                cache.items(id,2:cache.capacity(id)) = cache.items(setdiff(1:cache.capacity(id),i));
                cache.items(id,1) = vid;
            else
                cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
                cache.items(id,1) = vid;
            end
        case LFU
            %TODO global?
%             [n,bin] = histc(stats.watch(~isnan(stats.watch)),1:max(stats.watch)+1);
%             [vals, vids] = sort(n(n>0), 'descend');
% 
%                 nitems = min(length(vids), cache.capacity(id));
%                 cache.items(id,1:nitems) = vids(1:nitems);
            i = cache.items(id,:) == vid;
            if any(i)
                cache.score(id,i) = cache.score(id,i) + 1;
            else
                [~, last] = find(cache.items(id,:),1,'last');
                if isempty(last); last = 0; end
                repl = last + 1;
                if (repl > cache.capacity(id));
                    [~, repl] = min(cache.score(id,:));
                end
                cache.items(id,repl) = vid;
                cache.score(id,repl) = t;
            end
        case SLWND
            cache.wnd(id, 2:par.k) = cache.wnd(id,1:(par.k-1));
            cache.wnd(id, 1) = vid;
            %TODO here we continue
            scoreM = cache.wnd*ones(1,cache.capacity(id));
            i = cache.items(id,:) == vid;
            if ~any(i)
                cache.score
                [~, repl] = min(cache.score(id,:));
                cache.items(id,repl) = vid;
                cache.score(id,repl) = 1;
            end
        case GEOFD
            par.k
            par.rho
            ranking = stats.t
            %TBD
        case THRESH1
            %TBD
        case THRESH2
            %TBD
        case PERSONAL
            %TBD: cache only what is of personal interest, popular items are
            %in same AS anyhow...
            %how to figure out, what is of personal interest?
            %assume DHT
    end
    end
end
end