function par = addSNMParams(par)

par.snm.newVideoProb = 0.15;
par.snm.classes.perc = [85 0.54 0.795 0.495 0.795 12.36]; %percentage of videos - with class 0
%par.snm.classes.perc = [3.6 5.3 3.3 5.3 82.4]; %percentage of videos - original data
par.snm.classes.lifeSpan = [-1 1.1 3.4 6.4 10.7 24.2]; %lifespan in days - with class 0
%par.snm.classes.lifeSpan = [1.1 3.4 6.4 10.7 24.2]; %lifespan in days - original data
par.snm.classes.lifeSpan = par.snm.classes.lifeSpan * par.ticksPerDay;
%par.snm.classes.requests = [78.2 46 57 38.5 26.2]; %video request probability - estimated E[V_m]
par.snm.classes.requests = [2 9.1025 8.005 5.945 6.615 70.33]; %video request probability - measured %Reqs
par.snm.shareOnlyActive = true;

end