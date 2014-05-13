clear;

files = dir('results/cdsim_demandModel_SNM_13-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    fi = figure(f);
    plot(stats.snm.numActiveVids);
    
    figName = strcat('results/figs/cdsim_demandModel-', num2str(par.demand_model), '_newVidProb-', num2str(par.snm.newVideoProb), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_scaleOfIntAriTime-', num2str(par.ia_share_par(2)), '_number-', num2str(f));
    title(figName);
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end

%% test inter-arrival time
par.ia_share_rnd = 'gp';
par.ia_share_par = [1/1.5070 0.5 0];

numTrials = 6000;
stats = nan(1,numTrials);

for t=1:numTrials
    stats(t) = random(par.ia_share_rnd, par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));
end

plot(stats);
mean(stats)