function li13 = updateLI13(video, eventType, par, li13, numberOfFriends)

WATCH=1;
SHARE=2;
RESHARE=3;

if (eventType == WATCH)
    li13.v(video) = li13.v(video) + 1;
else
    li13.e(video) = li13.e(video) + binornd(numberOfFriends, par.li13.ViR);
end

li13.ev(video) = li13.e(video) + li13.v(video);
li13.p = li13.ev/sum(li13.ev);

end