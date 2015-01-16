function cache = updateCachePar(cache, stats, ids, vid, par)

LRU = 1;
LFU = 2;

items = cache.items(ids,:);
capacity = cache.capacity(ids);
cachingstrategy = cache.strategy(ids);

parfor ii=1:length(ids)
%    id = ids(ii);
    itemsi = items(ii,:);
    strategy = cachingstrategy(ii);
    switch strategy
        case LRU
            if itemsi(1) ~= vid
                i = itemsi == vid;
                if any(i) 
                    itemsi(2:capacity(ii)) = itemsi(~i(1:capacity(ii)));
                    itemsi(1) = vid;
                else
                    itemsi(2:capacity(ii)) = itemsi(1:capacity(ii)-1);
                    itemsi(1) = vid;
                end
            end


        case LRUSG % score gated
%             ranking
%             i =  cache.items(id,:) == vid;
%             if any(i) && cache.items(id,1) ~= vid
%                 cache.items(id,2:cache.capacity(id)) = cache.items(setdiff(1:cache.capacity(id),i));
%                 cache.items(id,1) = vid;
%             else
%                 cache.items(id,2:cache.capacity(id)) = cache.items(id,1:cache.capacity(id)-1);
%                 cache.items(id,1) = vid;
%             end
        case LFU
            %TODO optimize
            %TODO
%             [n,bin] = histc(stats.watch(~isnan(stats.watch)),1:max(stats.watch)+1);
%             [vals, vids] = sort(n(n>0), 'descend');
% 
%                 nitems = min(length(vids), capacity(id));
%                 itemsi(id,1:nitems) = vids(1:nitems);

        case SLWND
%             par.k
%             ranking
            %TBD
        case GEOFD
%             par.k
%             par.rho
%             ranking = stats.t
            %TBD
        case TRESH1
            %TBD
        case TRESH2
            %TBD
    end
    items(ii,:) = itemsi;
end
%cache.items(ids) = items;
[row, col, v] = find(items);
if (~iscolumn(ids)); ids = ids'; end
cache.items(sub2ind(size(cache.items),ids(row), col)) = v;
end