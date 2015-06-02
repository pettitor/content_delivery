function ciplot(x, data, fig, color, style)
figure(fig)
mittelwert = mean(data,2);
for i=1:size(data, 1) % über x-Werte gehen
    [hh, pp, ci] = ttest(data(i,:),mittelwert(i));
    cialle(i,:) = ci;
end
errorbar(x, mittelwert,cialle(:,1)-mittelwert,cialle(:,2)-mittelwert,style,...
   'Color',color,'LineWidth', 2, 'MarkerSize', 8);

end