function cache = updateCache(cache, AS, uid, vid, strategy, param)

switch lower(strategy)
    case {'lru'}
        i = cache(uid,:) == vid;
        if any(i)
            cache(uid,2:end) = cache(uid,~i);
            cache(uid,1) = vid;
        else
            cache(uid,2:end) = cache(uid,1:end-1);
            cache(uid,1) = vid;
        end
    case {'lfu'}
    case {'sl_wnd'}
    case {'geo_fd'}
        %TODO
    case {'tresh1'}
        
end

end