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
    snm.endOfLife(vid) = time + snm.videoLifeSpan(vid);
end

for e = snm.active
   if snm.endOfLife(vid) > time
       snm.active = snm.active(snm.active~=vid);
   end
end

end