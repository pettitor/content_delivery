clear;

files = dir('results/cdsim_demandModel_SNM_14-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    fi = figure(f);
    plot(stats.snm.numActiveVids);
    
    if par.snm.dayNightCycle.enabled
        tmps = strcat('dayNight-', num2str(par.snm.dayNightCycle.newVideoProbDay), '-', num2str(par.snm.dayNightCycle.newVideoProbNight));
    else
       tmps = num2str(par.snm.newVideoProb);
    end
    
    figName = strcat('results/figs/cdsim_demandModel-', num2str(par.demand_model), '_newVidProb-', tmps, '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_scaleOfIntAriTime-', num2str(par.ia_share_par(2)), '_number-', num2str(f));
    title(figName);
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end
%TODO specify new vid prob (empty vs full list)
%TODO initial phase vs 'normal' behaviour (drops into init phase if list empty)

%TODO plot cache hit rate for snm (different scenarios), li13

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