clear;

files = dir('results/cdsim_demandModel_SNM_12-May-2014*.mat');

for f=1:length(files)
    clear par stats;
    load(strcat('results/', files(f).name));
    
    fi = figure(f);
    plot(stats.snm.numActiveVids);
    title(files(f).name);
    
    figName = strcat('results/figs/', files(f).name);
    saveas(fi,strcat(figName, '.fig'),'fig');
    saveas(fi,strcat(figName, '.jpg'),'jpg');
end