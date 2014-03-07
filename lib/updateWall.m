function wall = updateWall(GF, wall, uid, vid)
    friends = find(GF(uid,:));
    for i=friends
        wall(i,2:end) = wall(i,1:end-1);
        wall(i,1) = vid;
    end
end