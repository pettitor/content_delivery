function [events, eid, evid] = adjustServiceTimes(events, cid, now, tmax, factor)

    ind = find(events.type == 6 & events.user == cid);

    %TODO should not happen
    if isempty(ind); 
        eid = [];
        evid = [];
        return;
    end
    
    et = events.t(ind);
    euser = events.user(ind);
    eid = events.id(ind);
    evid = events.vid(ind);
   
    etn = now+max(0,(et-now)*factor);
    
    events.t(ind) = etn;
%     
%     istart = find(diff(events.t)<0);
   
%     istart = [];
%     for i=1:length(ind)-1;
%     istart = find(events.t(ind(i)+1:ind(i+1)) < etn(i),1,'first');
%     if istart; break; end;
%     end
%     if isempty(istart)
%         istart = find(events.t(ind(end)+1:end) < etn(end),1,'first');
%         i = length(ind);
%     end
    
%     if istart
%         i = find(ind == istart);
%     
%         while(i>1 && (ind(i-1) == ind(i)-1))
%             i = i-1;
%         end
%         
%         iend = find(events.t(ind(end)+1:end) > etn(end),1,'first');
%         if isempty(iend); iend = length(events.t)-ind(end)+1; end
%         index = ind(i):ind(end)+iend-1;
%         
        [events.t, idx] = sort(events.t);
        events.type = events.type(idx);
        events.user = events.user(idx);
        events.id = events.id(idx);
        events.vid = events.vid(idx);
% 
%     end

%     for i=1:length(ind)
%         istart = find(events.t(ind(i)+1:end) < etn(i),1,'first')+ind(i);
%         if istart
%             iend = find(events.t(istart:end) > etn(i),1,'first')+ind(i)-1;
%             if isempty(iend); iend = length(events.t); end
%             index = istart:iend;

%             events.t = [events.t(1:(ind(i)-1)) events.t(index) events.t(ind(i):end)];
%             events.type = [events.type(1:(ind(i)-1)) events.type(index) events.type(ind(i):end)];
%             events.user = [events.user(1:(ind(i)-1)) events.user(index) events.user(ind(i):end)];
%             events.id = [events.id(1:(ind(i)-1)) events.id(index) events.id(ind(i):end)];
%             events.vid = [events.vid(1:(ind(i)-1)) events.vid(index) events.vid(ind(i):end)];
%             
%             
%             events.t(index+length(index)) = [];
%             events.type(index+length(index)) = [];
%             events.user(index+length(index)) = [];
%             events.id(index+length(index)) = [];
%             events.vid(index+length(index)) = [];
%             
%             ind = ind + length(index);
%     end
    
%     events.t(ind) = [];
%     events.type(ind) = [];
%     events.user(ind) = [];
%     events.id(ind) = [];
%     events.vid(ind) = [];
%     
%      for i=1:length(ind)
%         events = addEvent(events, etn(i), tmax, 6, euser(i), eid(i), evid(i));
%      end
end