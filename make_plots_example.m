% this script makes a figure for each gneotype that shows:
% 1. some example trajectories
% 2. 2 images (r-theta) averaged over all frames for 1 fly
% 3. images (r-theta) averaged over all frames for all flies


% first combine all images file and subsample for 
% easy access
ssdata = smooth_images(10);


c = lines;

options.trx_folder = '~/Desktop/fly-trx';

geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};


for i = 1:max(ssdata.geno_id)

	load([options.trx_folder filesep geno_names{i}])
	x = vertcat(trx.x_mm);
	y = vertcat(trx.y_mm);
	all_theta = vertcat(trx.theta);


	figure('outerposition',[0 0 1500 500],'PaperUnits','points','PaperSize',[1500 500]); hold on
	subplot(1,3,1); hold on

	for j = 1:3
		plot(x(j,:),y(j,:),'.','Color',c(j,:))
	end

	axis square
	title(geno_names{i}(1:20),'interpreter','none')
	axis off
	set(gca,'XLim',[-60 60],'YLim',[-60 60])

	% show the average image for the first fly
	subplot(1,3,2); hold on
	idx = ssdata.fly_id==1 & ssdata.geno_id == i;
	temp = squeeze(mean(ssdata.images(idx,:,:)));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('One fly')

	% show the average image for the all flies
	subplot(1,3,3); hold on
	idx = ssdata.geno_id==i;
	temp = squeeze(mean(ssdata.images(idx,:,:)));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('All flies')

	prettyFig();

	drawnow
	

end
