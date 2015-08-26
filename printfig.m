function printfig(h, name)
gcf = h;
allFont=[findall(gcf,'type','text');findall(gcf,'type','axes')];
set(allFont,'fontsize', 18);
%set(allFont,'fontname', 'times');
%set(allFont,'fontname', 'helvetica');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [8 6]);
set(gcf, 'PaperPosition', [0 0 8 6]);
figname = name;
print (gcf, '-dpdf', ['figs/pdf/' figname]);
print (gcf, '-depsc', ['figs/eps/' figname]);
saveas(gcf, ['figs/fig/' figname])

end