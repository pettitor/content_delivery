function [cache hit] = updateCache(cache, AS, uid, vid, strategy, param)
hit = 0;
switch lower(strategy)
    case {'lru'}
        i = cache(uid,:) == vid;
        if any(i)
            cache(uid,2:end) = cache(uid,~i);
            cache(uid,1) = vid;
            hit = 1;
        else
            cache(uid,2:end) = cache(uid,1:end-1);
            cache(uid,1) = vid;
        end
    case {'lfu'}
        %TBD
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