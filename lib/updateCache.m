function cache = updateCache(cache, stats, ids, vid, par)

LRU = 1;
LFU = 2;

for ii=1:length(ids)
    id = ids(ii);
    switch par.cachingstrategy(cache.type(id))
        case LRU
            if cache.items(id,1) ~= vid
                i = cache.items(id,:) == vid;
                if any(i)
                    cache.items(id,2:cache.capacity(id)) = cache.items(id,~i(1:cache.capacity(id)));
                    cache.items(id,1) = vid;
                else
                    cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
                    cache.items(id,1) = vid;
                end
            end

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
            %TODO optimize
            %TODO
            [n,bin] = histc(stats.watch(~isnan(stats.watch)),1:max(stats.watch)+1);
            [vals, vids] = sort(n(n>0), 'descend');

                nitems = min(length(vids), cache.capacity(id));
                cache.items(id,1:nitems) = vids(1:nitems);

        case SLWND
            par.k
            ranking
            %TBD
        case GEOFD
            par.k
            par.rho
            ranking = stats.t
            %TBD
        case THRESH1
            %TBD
        case THRESH2
            %TBD
    end
end
end