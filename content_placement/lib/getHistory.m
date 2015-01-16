function h = getHistory(uid, stats, timelag)

if nargin < 3
    index = stats.uid == uid & ~isnan(stats.watch);
    h = stats.watch(index);
end

end