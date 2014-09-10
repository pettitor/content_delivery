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

%seeds = [234]; %, 567];
seeds = [234];
% new study with separated LIs
constants;

%% li13 custom part (in one block)
constants;

par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
par.ia_demand_par = par.ia_demand_par_seconds*0.5;%*par.ticksPerSecond;

par.demand_model = LI13Custom;
par.sharing_model = LI13Custom;
%all possible combinations concerning upload events and attenuations
%combis = [0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1];
%combis = [0 0 1];
%par.tmax = 3e3;
for j=1:length(seeds)
    %for i=1:size(combis,1)
%         par.shareAttenuation = combis(i,1);
%         par.viewAttenuation = combis(i,2);
%         par.uploadEvents = combis(i,3);
        par.shareAttenuation = 1;
        par.viewAttenuation = 1;
        par.uploadEvents = 1;
        par.probabilityEquality = 0;
        par.viewAttenuationNew = 0;
        
        if (par.uploadEvents)
            par.ia_demand_par_seconds = 4*ones(1,24);
            par.ia_demand_par = par.ia_demand_par_seconds;
        else
            par.ia_demand_par_seconds = [2.89 5.11 11.41 20.61 29.05 21.63 10.59 5.66 3.23 2.42 2.00 1.69 0.08 0.21 0.09 0.06 0.10 0.10 0.07 0.09 0.08 0.01 0.13 0.16]; % ia time in seconds
            par.ia_demand_par = par.ia_demand_par_seconds*0.5;
        end
        
        clear('stats');
        par.seed = seeds(j);
        tic
        stats = cdsim(par);
        toc

        name = [date '_seed_' num2str(par.seed) '_demandModel_' num2str(par.demand_model) '_attView_' num2str(par.viewAttenuation) '_attShare_' num2str(par.shareAttenuation) '_uploadEvents_' num2str(par.uploadEvents)];
        save(['results/cdsim_' name '.mat'], 'par', 'stats')

    %end
end

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