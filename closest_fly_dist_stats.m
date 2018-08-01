% show plots of closest fly dist


figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
load('closest_fly_dist.mat','closest_fly_dist')

subplot(1,2,1); hold on

[hy,hx] = histcounts(closest_fly_dist,1e3);
hx = hx(1:end-1) + mean(diff(hx))/2;
hy = hy/sum(hy);
stairs(hx,cumsum(hy),'k')

c = parula(12);

for i = 1:10
	[hy,hx] = histcounts(closest_fly_dist(all_geno==i),1e3);
	hx = hx(1:end-1) + mean(diff(hx))/2;
	hy = hy/sum(hy);
	stairs(hx,cumsum(hy),'Color',c(i,:))
end

xlabel('Distance to closest fly (mm)')
set(gca,'XScale','log','XLim',[1 100])
ylabel('Cumulative prob.')


prettyFig();