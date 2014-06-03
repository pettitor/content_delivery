%% active videos snm
clear;

files = dir('results/cdsim_demandModel_SNM_03-Jun-2014*.mat');

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
    
    figName = strcat('results/figs/cdsim_demandModel-', num2str(par.demand_model), '_newVidProb-', num2str(par.snm.newVideoProb), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    title('Number of active videos');
    xlabel('Time (ticks)');
    ylabel('Number of active videos');
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end
%TODO specify new vid prob (empty vs full list)
%TODO initial phase vs 'normal' behaviour (drops into init phase if list empty)

%TODO plot cache hit rate for snm (different scenarios), li13

%% plot views (log log)
clear;

files = dir('results/cdsim_demandModel_SNM_03-Jun-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    views = stats.views;%(stats.views~=0);
    views = sort(views, 'descend');
    
    fi = figure(f);
    loglog(views)
    
    
    axis([0 10^4 0 10^4]);
    xlabel('Video index (ranked by popularity)');
    ylabel('Number of requests');
    
    figName = strcat('results/figs/cdsim_loglog_demandModel-', num2str(par.demand_model), '_newVidProb-', num2str(par.snm.newVideoProb), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end
%% probability density
clear;

files = dir('results/cdsim_demandModel_SNM_03-Jun-2014*.mat');

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

%% plot views

clear;

files = dir('results/cdsim_demandModel_SNM_03-Jun-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    watch = stats.watch(~isnan(stats.watch));
    t = stats.t(~isnan(stats.watch));
    
    fi = figure(f);
    hold all;
    plot(t,watch,'.')
    
    for i=1:floor(par.tmax/par.ticksPerDay)
        v = par.ticksPerDay*i;
        line([v v],get(gca,'YLim'));
    end
    
    xlabel('Time (ticks)');
    ylabel('Number of requests');
    
    
    figName = strcat('results/figs/cdsim_diurnal_demandModel-', num2str(par.demand_model), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    saveas(fi,strcat(figName, '.jpg'),'jpg');
    
end

%% eval classes

videoClasses = stats.snm.classes(stats.watch(~isnan(stats.watch)));
requestPercentage = zeros(1, length(par.snm.classes.perc));

for i=1:length(par.snm.classes.perc)
   requestPercentage(i) = length(videoClasses(videoClasses==i))/length(videoClasses)*100;
end
requestPercentage