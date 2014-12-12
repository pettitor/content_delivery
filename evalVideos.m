filePattern = 'results/cdsim_12-Nov-2014_seed_567*.mat';
%% active videos snm
files = dir(filePattern);

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
    title('Number of active videos' + files(f).name);
    xlabel('Time (ticks)');
    ylabel('Number of active videos');
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end
%TODO specify new vid prob (empty vs full list)
%TODO initial phase vs 'normal' behaviour (drops into init phase if list empty)

%TODO plot cache hit rate for snm (different scenarios), li13

%% plot views (log log)
filePattern = 'results/cdsim_*-*.mat';
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    views = stats.views;%(stats.views~=0);
    views = sort(views, 'descend');
    
    fi = figure(f+1);
    %hold on
    
    ydata = log10(views+1)';
    xdata = log10(1:length(views))+1;

    %f=@(a,xdata)a(1).*xdata.^(-a(2));
    %flog=@(a,xdata)a(1)+xdata.*(-a(2));

    %a = lsqcurvefit(flog,[4 2],xdata,ydata)
    
    clf
    %loglog(views,'.')
    plot(xdata,ydata);
    hold all
    plot(xdata,ydata,'.');
    plot([1 6],5*[1 6].^-0.85);
    %plot(xdata,flog(a, xdata));
    
    %plot([1e1 1e3],10e3*[1e1 1e3].^-0.6)
    
    %set(gca,'xscale','log','yscale','log')
    axis([1 6 0 6]);
    title(files(f).name);
    xlabel('Video index (ranked by popularity)');
    ylabel('Number of requests');
    
    %hold off
    
    name = ['loglog_li13_diurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    figName = ['results/figs/cdsim_demandModel_' num2str(par.demand_model) '_' date];
    %figName = strcat('results/figs/cdsim_loglog_demandModel-', num2str(par.demand_model), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    saveas(fi,['results/figs/loglog_' files(f).name '.jpg'],'jpg');
end
%% probability density
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    views = stats.views(stats.views~=0);
    
    fi = figure(f);
    n = hist(views,0:max(views));
    views = sort(views, 'descend');
    
    
    plot(0:max(views),n/sum(views),'.')
    set(gca,'xscale','log','yscale','log')
    title(files(f).name);
    
end

%% plot views
files = dir(filePattern);

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
    title(files(f).name);
    
    
    figName = strcat('results/figs/cdsim_diurnal_demandModel-', num2str(par.demand_model), '_ticksPerDay-', num2str(par.ticksPerDay), '_ticks-', num2str(par.tmax), '_number-', num2str(f));
    saveas(fi,strcat(figName, '.jpg'),'jpg');
    
end

%% requests per class (percentage)
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));

    videoClasses = stats.snm.classes(stats.watch(~isnan(stats.watch)));
    requestPercentage = zeros(1, length(par.snm.classes.perc));

    for i=1:length(par.snm.classes.perc)
       requestPercentage(i) = length(videoClasses(videoClasses==i))/length(videoClasses)*100;
    end
    files(f).name
    requestPercentage
end

%% requests per class (mean)
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    videoClasses = stats.snm.classes;
    views = stats.views;
    numberOfRequests = zeros(1, length(par.snm.classes.perc));

    for i=1:length(par.snm.classes.perc)
       numberOfRequests(i) =  mean(views(videoClasses==i));
    end

    files(f).name
    numberOfRequests
end

%% temporal locality
%fuer 10 populaeresten videos
files = dir(filePattern);
color = gray(11);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    [b,idx] = sort(stats.views,'descend');
    vids = idx(1:10); %populaeresten videos
    fi = figure(f)
    clf;box on;hold all;
    for i=1:length(vids)
        a = stats.t(stats.watch == vids(i));

        c = histc(a-min(a),0:4:par.tmax-min(a));
        plot(1:length(c), c, '.', 'Color',color(i,:));
    end
    
    
    title(files(f).name);
    %x: 800
    %y: 90
    
    saveas(fi,['results/figs/temporalLocality_' files(f).name '.jpg'],'jpg');
end

%% lifespan verteilung
files = dir(filePattern);
color = gray(11);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    %[b,idx] = sort(stats.views,'descend');
  
    lifespan = nan(1,par.nvids);
    fi = figure(f)
    clf;box on;hold all;
    for i=1:par.nvids
        a = stats.t(stats.watch == i);

        if(~isempty(a))
            lifespan(i) = max(a)-min(a);
        else
            lifespan(i) = 0;
        end
    end
    
    c = histc(lifespan,1:par.ticksPerDay:par.tmax);
    plot(c,'.')
    
    title(files(f).name);
    %x: 800
    %y: 90
    
    saveas(fi,['results/figs/temporalLocality_' files(f).name '.jpg'],'jpg');
end

%% lifespan verteilung - meherere sims in einem plot
files = dir(filePattern);
color = gray(11);

marker = {'.--','d-'};

fi = figure(2)
clf;box on;hold all;
for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    %[b,idx] = sort(stats.views,'descend');
  
    lifespan = nan(1,par.nvids);
    %fi = figure(f)
    %clf;box on;hold all;
    for i=1:par.nvids
        a = stats.t(stats.watch == i);

        if(~isempty(a))
            lifespan(i) = max(a)-min(a);
        else
            lifespan(i) = 0;
        end
    end
    
    c = histc(lifespan,1:par.ticksPerDay:par.tmax);
    plot(c,marker{f})
    
    title(files(f).name);
    %axis([0 35 0 250]);
    %x: 800
    %y: 90
    
    %saveas(fi,['results/figs/temporalLocality_' files(f).name '.jpg'],'jpg');
end
saveas(fi,['results/figs/temporalLocality_all.jpg'],'jpg');

%% number request per time period
%just for the x top most popular videos
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    [b,idx] = sort(stats.views,'descend');
    vids = idx(1:5); %populaeresten videos
    for i=1:length(vids)
        a = stats.t(stats.watch == vids(i));

        %96 ticks = one day -> 12 ticks = 3 hours
        c(:,i) = histc(a,0:12:par.tmax);
    end
    
    fi = figure(f)
    clf;box on;hold all;
    title(files(f).name);
    bar(c);
    %axis([0 30 0 2500]);
    
    saveas(fi,['results/figs/temporalLocality_' files(f).name '.jpg'],'jpg');
end

%% cache hit ratio
filePattern = 'results/cacheHit/cdsim_05-Nov-2014_seed_234_demandModel_8_lifeSpanMode_1_cachesizeAS_*.mat';
files = dir(filePattern);

for f=1:length(files)
    clear par stats;
    load(strcat('results/cacheHit/', files(f).name));
    
    disp(files(f).name);
    stats.cache_hit./stats.cache_access
end

%% plot cache hit ratio
%filePattern = 'results/cacheHit/cdsim_12-Nov-2014_seed_234_demandModel_6_lifeSpanMode_1_cachesizeAS_*.mat';
%filePattern = 'results/cacheHit/cdsim_12-Nov-2014_seed_567_demandModel_6_lifeSpanMode_1_cachesizeAS_*.mat';
%filePattern = 'results/cacheHit/cdsim_05-Nov-2014_seed_234_demandModel_8_lifeSpanMode_1_cachesizeAS_*.mat';
%filePattern = 'results/cacheHit/cdsim_05-Nov-2014_seed_567_demandModel_8_lifeSpanMode_1_cachesizeAS_*.mat';


constants;
LI13LS = 9;
LI13LSLRU = 10;
seeds = [234];%, 567];
demanModels = [ZIPF2, boxModel, LI13, LI13LS, LI13LSLRU];
demandModel = {'ZIPF','WALL','YTSTATS','SNM','LI13 - LRU','ZIPF2','LI13Custom','BoxModel', 'LI13 - LS', 'LI13 - LS and LRU'};
%mean ueber versch. seeds
%1 plot with all box models
%1 plot with all zipfs

basePattern = 'results/cacheHit/cdsim_*';
for d=1:length(demanModels)
    pattern = [basePattern '_demandModel_' num2str(demanModels(d)) '*'];
    files = dir(pattern);
    cacheHitRatio = NaN(1, length(files));
    cacheSize = NaN(1, length(files));
    seed = NaN(1, length(files));
    for f=1:length(files)
        clear par stats;
        load(strcat('results/cacheHit/', files(f).name));
        
        r = stats.cache_hit./stats.cache_access;
    
        cacheHitRatio(f) = r;
        cacheSize(f) = par.cachesizeAS;
        seed(f) = par.seed;
    end
    
    figure(d)
    plot(cacheSize, cacheHitRatio, '.');
    title(['Demand Model: ' demandModel(demanModels(d))])
    set(gca,'xscale','log')
    xlabel('cache Size')
    ylabel('cache Hit Ratio')

    axis([0 1 0 1]);
end