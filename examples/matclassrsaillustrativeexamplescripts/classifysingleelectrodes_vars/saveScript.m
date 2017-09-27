% ax = gca;
% ax.Clipping = 'off';
% v = get(gca,'Position');
% set(gca,'Position',[v(1)*1.1 v(2) v(3:4)]);
% fig = gcf;
% fig.PaperPositionMode = 'auto';


set(gcf,'Units','points')
set(gcf,'PaperUnits','points') 


size = get(gcf,'Position');
size = size(3:4);
set(gcf,'PaperSize',size)

set(gcf,'PaperPosition',[0,0,size(1),size(2)])

% saveas(gcf, 'Egi', 'epsc');
print (gcf, 'Egi', '-depsc', '-loose')
saveas(gcf, 'Egi', 'fig');