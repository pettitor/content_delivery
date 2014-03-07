function events = addEvent(events, t, type, user, id)

index = find(events.t > t, 1, 'first'); if (isempty(index)) index = length(events.t)+1; end

events.t = [events.t(1:(index-1)) t events.t(index:end)];
events.type = [events.type(1:(index-1)) type events.type(index:end)];
events.user = [events.user(1:(index-1)) user events.user(index:end)];
events.id = [events.id(1:(index-1)) id events.id(index:end)];

end
