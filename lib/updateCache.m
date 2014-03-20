function cache = updateCache(cache, stats, id, vid, strategy, param)

switch lower(strategy)
    case {'lru'}
        i = cache.items(id,:) == vid;
        if any(i) && cache.items(id,1) ~= vid
            cache.items(id,2:cache.capacity(id)) = cache.items(setdiff(1:cache.capacity(id),i));
            cache.items(id,1) = vid;
        else
            cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
            cache.items(id,1) = vid;
        end

    case {'lru_sg'} % score gated
        i = cache.items(id,:) == vid;
        if any(i) && cache.items(id,1) ~= vid
            cache.items(id,2:cache.capacity(id)) = cache.items(setdiff(1:cache.capacity(id),i));
            cache.items(id,1) = vid;
        else
            cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
            cache.items(id,1) = vid;
        end
    case {'lfu'}
        %TODO optimize
        %TODO
        [n,bin] = histc(stats.watch(~isnan(stats.watch)),1:max(stats.watch)+1);
        [vals, vids] = sort(n(n>0), 'descend');
        nitems = min(length(vids), cache.capacity(id));
        cache.items(id,1:nitems) = vids(1:nitems);
    case {'sl_wnd'}
        %TBD
    case {'geo_fd'}
        %TBD
    case {'tresh1'}
        %TBD
    case {'tresh2'}
        %TBD
end

end