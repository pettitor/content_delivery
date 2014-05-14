function par = addSNMParams(par)

par.snm.newVideoProb = 0.25;
par.snm.classes.perc = [3.6 5.3 3.3 5.3 82.4];
par.snm.classes.lifeSpan = [1.1 3.4 6.4 10.7 24.2]; %lifespan in days
par.snm.classes.lifeSpan = par.snm.classes.lifeSpan * par.ticksPerDay;
par.snm.classes.requests = [78.2 46 57 38.5 26.2];
par.snm.dayNightCycle.enabled = true;
par.snm.dayNightCycle.dayTime = [8 20];
par.snm.dayNightCycle.newVideoProbDay = 0.4;
par.snm.dayNightCycle.newVideoProbNight = 0.1;
par.snm.shareOnlyActive = true;

end