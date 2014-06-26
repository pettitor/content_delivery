% clear

clear par stats

% add library

addpath('lib');
addpath('lib/randraw');
addpath('lib/snm');
addpath('lib/li13');

%%%%% Parameters

%%% load default Parameters

parRBHORST;

attenution = [0.014 0.015 0.016 0.017 0.018 0.019 0.020 0.021 0.022 0.023 0.024];

for i=1:length(attenution)
    par.tmpAttenuationExp = attenution(i);
    tic
    stats = cdsim(par);
    toc

    %%% Save Results
    ZIPF = 1;
    WALL = 2;
    YTSTATS = 3;
    SNM = 4;
    LI13 = 5;
    demandModel =  '';
    switch par.demand_model
        case ZIPF
            demandModel = 'ZIPF';
        case WALL
            demandModel = 'WALL';
        case YTSTATS
            demandModel = 'YTSTATS';
        case SNM
            demandModel = 'SNM';
        case LI13
            demandModel = 'LI13';
    end

    save(['results/cdsim_demandModel_' demandModel '_' date '_atte' num2str(par.tmpAttenuationExp) '.mat'], 'par', 'stats')
    
    views = stats.views;
    views = sort(views, 'descend');
    
    fi = figure(i);
    loglog(views)
   
    title(['Attenution: ' num2str(par.tmpAttenuationExp)]);
    xlabel('Video index (ranked by popularity)');
    ylabel('Number of requests');
    
    figName = ['results/figs/cdsim_demandModel_' demandModel '_' date '_atte' num2str(par.tmpAttenuationExp) '.jpg'];
    saveas(fi,figName,'jpg');
end