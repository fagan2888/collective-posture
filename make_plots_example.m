% this script makes a figure for each gneotype that shows:
% 1. some example trajectories
% 2. 2 images (r-theta) averaged over all frames for 1 fly
% 3. images (r-theta) averaged over all frames for all flies


close all

c = lines;

options.trx_folder = '~/Desktop/fly_trx';

geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};


geno_idx = 2;
body_size = 2;


load([options.trx_folder filesep geno_names{geno_idx}])
x = vertcat(trx.x_mm);
y = vertcat(trx.y_mm);
all_theta = vertcat(trx.theta);


figure('outerposition',[0 300 1560 400],'PaperUnits','points','PaperSize',[1560 400]); hold on
for i = 4:-1:1
	ax(i) = subplot(1,4,i);
	if i ~= 2
		hold(ax(i),'on')
	end
end

drawnow


for j = 1:3
	plot(x(j,:),y(j,:),'.','Color',c(j,:))
end
axis square
title(geno_names{geno_idx}(1:20),'interpreter','none')
axis off
set(gca,'XLim',[-60 60],'YLim',[-60 60])




load([geno_names{geno_idx} '.ego'],'-mat')


% show the average image for the first fly

idx = fly_id==1;
temp = squeeze(mean(all_images(idx,:,:),1));
imagesc(ax(3),temp)
xlabel(ax(3),'\Theta')
ylabel(ax(3),'R (a.u.)')

set(ax(3),'XTick',linspace(1,size(temp,2),5), 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
axis(ax(3),'tight')
title(ax(3),'One fly')


% show the average image for the all flies
temp = squeeze(mean(all_images,1));
imagesc(ax(4),temp)
xlabel(ax(4),'\Theta')
ylabel(ax(4),'R (a.u.)')
set(ax(4),'XTick',linspace(1,size(temp,2),5), 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
axis(ax(4),'tight')
title(ax(4),'All flies')




bin_size = 100;
bin_step = 10;


% show a movie of the fly in
% egocentric co-ordinats
load([geno_names{geno_idx} '.rtheta'],'-mat')
R = R/body_size;

axes(ax(2))
h = polarplot(vectorise(squeeze(T(1:bin_size,1,:))),vectorise(squeeze(R(1:bin_size,1,:))),'k.','MarkerSize',16);

ax = gca;
ax.RLim = [0 20];

prettyFig();

pause(7)

for i = 1:bin_step:length(T)-bin_size+10
	h.ThetaData = vectorise(squeeze(T(i:i+bin_size,1,:)));
	h.RData = vectorise(squeeze(R(i:i+bin_size,1,:)));
	drawnow
end


