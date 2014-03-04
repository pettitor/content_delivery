function wall = updateWall(GF, wall, uid, vid)
    friends = find(GF(uid,:));
    for i=friends
        wall(:,i) = [vid; wall(1:end-1,i)];
    end
end