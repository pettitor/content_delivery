%% active videos snm
clear;

files = dir('results/cdsim_demandModel_SNM_17-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    fi = figure(f);
    hold all;
    plot(stats.snm.time, stats.snm.numActiveVids);
    
    for i=1:floor(par.tmax/par.ticksPerDay)
        v = par.ticksPerDay*i;
        line([v v],get(gca,'YLim'));
    end
    
    tmps = num2str(par.snm.newVideoProb);
    
    figName = strcat('results/figs/cdsim_demandModel-', num2str(par.demand_model), '_newVidProb-', tmps, '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    title(figName);
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end
%TODO specify new vid prob (empty vs full list)
%TODO initial phase vs 'normal' behaviour (drops into init phase if list empty)

%TODO plot cache hit rate for snm (different scenarios), li13

%% plot views (log log)
clear;

files = dir('results/cdsim_demandModel_ZIPF_17-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    views = stats.views(stats.views~=0);
    views = sort(views, 'descend');
    
    fi = figure(f);
    loglog(views)
    
end
%% probability density
clear;

files = dir('results/cdsim_demandModel_ZIPF_17-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    views = stats.views(stats.views~=0);
    
    fi = figure(f);
    n = hist(views,0:max(views));
    %views = sort(views, 'descend');
    
    plot(0:max(views),n/sum(views),'.')
    set(gca,'xscale','log','yscale','log')
    
end