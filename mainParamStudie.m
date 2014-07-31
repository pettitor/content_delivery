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

seeds = [234, 567];
%% just a small test
par.shareAttenuation = true;
par.viewAttenuation = true;

clear('stats');
par.seed = seeds(1);
tic
stats = cdsim(par);
toc

name = ['li13_diurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
save(['results/cdsim_demandModel_' name '_1.mat'], 'par', 'stats')


%% diurnal vs non-diurnal | no attenuation
par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16];
par.shareAttenuation = false;
par.viewAttenuation = false;

for j=1:length(seeds)
    clear('stats');
    par.seed = seeds(j);
    tic
    stats = cdsim(par);
    toc

    name = ['li13_diurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
end

par.ia_demand_par_seconds = ones(1,24);
for j=1:length(seeds)
    clear('stats');
    par.seed = seeds(j);
    tic
    stats = cdsim(par);
    toc

    name = ['li13_noDiurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
end


% both attenuation vs share attenuation vs view attenuation vs no attenuation | not diurnal
par.ia_demand_par_seconds = ones(1,24);

par.shareAttenuation = true;
par.viewAttenuation = true;
for j=1:length(seeds)
    clear('stats');
    par.seed = seeds(j);
    tic
    stats = cdsim(par);
    toc

    name = ['li13_noDiurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
end

par.shareAttenuation = true;
par.viewAttenuation = false;
for j=1:length(seeds)
    clear('stats');
    par.seed = seeds(j);
    tic
    stats = cdsim(par);
    toc

    name = ['li13_noDiurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
end

par.shareAttenuation = false;
par.viewAttenuation = true;
for j=1:length(seeds)
    clear('stats');
    par.seed = seeds(j);
    tic
    stats = cdsim(par);
    toc

    name = ['li13_noDiurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
    save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
end

%simulated above
% par.shareAttenuation = false;
% par.viewAttenuation = false;
% for j=1:length(seeds)
%     clear('stats');
%     par.seed = seeds(j);
%     tic
%     stats = cdsim(par);
%     toc
% 
%     name = ['li13_noDiurnal_' date '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_seed_' num2str(par.seed)];
%     save(['results/cdsim_demandModel_' name '.mat'], 'par', 'stats')
% end


%% attenution (with different seeds)
attenution = [0.017 0.023];
seed = randi(1000,3,1); %(maxInt,lengthOfArray,widthOfArray)

for j=1:length(seed)
    par.seed = seed(j);
    for i=1:length(attenution)
        clear('stats');
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

        save(['results/cdsim_demandModel_' demandModel '_' date '_atte' num2str(par.tmpAttenuationExp) '_rnd' num2str(par.seed) '.mat'], 'par', 'stats')

        views = stats.views;
        views = sort(views, 'descend');

        fi = figure(i);
        loglog(views)

        title(['Attenution: ' num2str(par.tmpAttenuationExp) ', Seed: ' num2str(par.seed)]);
        xlabel('Video index (ranked by popularity)');
        ylabel('Number of requests');

        figName = ['results/figs/cdsim_demandModel_' demandModel '_' date '_atte' num2str(par.tmpAttenuationExp) '_rnd' num2str(par.seed) '.jpg'];
        saveas(fi,figName,'jpg');
    end
end