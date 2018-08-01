% show polar plot movies

all_files = dir('*.rtheta');

idx = 1;

load(all_files(idx).name,'-mat')


bin_size = 100;
bin_step = 10;


figure('outerposition',[0 0 700 701],'PaperUnits','points','PaperSize',[700 701]); 

h = polarplot(vectorise(squeeze(T(1:bin_size,1,:))),vectorise(squeeze(R(1:bin_size,1,:))),'k.','MarkerSize',24);

ax = gca;
ax.RLim = [0 40];

title(all_files(idx).name(1:20),'interpreter','none')

prettyFig();



for i = 1:bin_step:length(T)-bin_size+10
	h.ThetaData = vectorise(squeeze(T(i:i+bin_size,1,:)));
	h.RData = vectorise(squeeze(R(i:i+bin_size,1,:)));
	drawnow
end