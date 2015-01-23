function events = adjustServiceTimes(events, cid, now, tmax, factor)

    ind = (events.type == 6 & events.user == cid);
    
    et = events.t(ind);
    euser = events.user(ind);
    eid = events.id(ind);
    evid = events.vid(ind);
   
    et = now+(et-now)*factor;
    
    events.t(ind) = [];
    events.type(ind) = [];
    events.user(ind) = [];
    events.id(ind) = [];
    events.vid(ind) = [];
    
    for i=1:length(et)
       events = addEvent(events, et(i), tmax, 6, euser(i), eid(i), evid(i));
    end
end