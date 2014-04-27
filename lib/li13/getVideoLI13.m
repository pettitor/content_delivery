function vid = getVideoLI13(li13)

cumSum = cumsum(li13.p);
rnd = rand();

idx = find(rnd <= cumSum, 1, 'first'); %find the category for random number

if (~isempty(idx))
    vid = idx;
else
    vid = randi(length(P));
end

end

