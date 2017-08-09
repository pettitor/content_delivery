function events = addEvent(events, t, tmax, type, user, id, vid)

if (t <= tmax || type == 6) % do not drop serve events
    index = events.t > t;

    events.t = [events.t(~index) t events.t(index)];
    events.type = [events.type(~index) type events.type(index)];
    events.user = [events.user(~index) user events.user(index)];
    events.id = [events.id(~index) id events.id(index)];
    events.vid = [events.vid(~index) vid events.vid(index)];
end

end
