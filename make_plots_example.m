% this script makes a figure for each gneotype that shows:
% 1. some example trajectories
% 2. 2 images (r-theta) averaged over all frames for 1 fly
% 3. images (r-theta) averaged over all frames for all flies




c = lines;

options.trx_folder = '~/Desktop/fly-trx';

geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};


for i = 1:length(geno_names)

	load([options.trx_folder filesep geno_names{i}])
	x = vertcat(trx.x_mm);
	y = vertcat(trx.y_mm);
	all_theta = vertcat(trx.theta);


	figure('outerposition',[0 0 701 700],'PaperUnits','points','PaperSize',[701 700]); hold on
	subplot(2,2,1); hold on

	for j = 1:3
		plot(x(j,:),y(j,:),'.','Color',c(j,:))
	end
	axis square
	title(geno_names{i}(1:20),'interpreter','none')
	axis off
	set(gca,'XLim',[-60 60],'YLim',[-60 60])


	% now show these in egocentric co-ordinats
	load([geno_names{i} '.rtheta'],'-mat')
	
	subplot(2,2,2); 
	n_frames = 300;
	polarplot(squeeze(T(1:n_frames,1,:)),squeeze(R(1:n_frames,1,:)),'.','Color',c(1,:))
	ax = gca;
	hold on
	for j = 2:3
		polarplot(squeeze(T(1:n_frames,j,:)),squeeze(R(1:n_frames,j,:)),'.','Color',c(j,:))
	end
	ax.RLim = [0 40];


	load([geno_names{i} '.ego'],'-mat')

	% show the average image for the first fly
	subplot(2,2,3); hold on
	idx = fly_id==1;
	temp = squeeze(mean(all_images(idx,:,:),1));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('One fly')

	% show the average image for the all flies
	subplot(2,2,4); hold on
	temp = squeeze(mean(all_images,1));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('All flies')

	prettyFig();

	drawnow
	

end
