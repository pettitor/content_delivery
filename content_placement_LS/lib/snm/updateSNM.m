function snm = updateSNM(vid, snm, time)

%if vid in unseen
% - put in active
% - remove from unseen
% - setEndOfLife (time + snm.videoLifeSpan)
%for all vids in active
% - check life time (if exceeded remove from active)
if any(snm.unseen == vid)
    snm.unseen = snm.unseen(snm.unseen~=vid);
    snm.active = [snm.active vid];
    if snm.videoLifeSpan(vid) == -1
        snm.endOfLife(vid) = -1;    
    else 
        snm.endOfLife(vid) = time + snm.videoLifeSpan(vid);
    end
end

for e = snm.active
   if snm.endOfLife(e) < time && snm.endOfLife(e) ~= -1
       snm.active = snm.active(snm.active~=e);
   end
end

end