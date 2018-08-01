% this script makes a figure for each gneotype that shows:
% 1. some example trajectories
% 2. 2 images (r-theta) averaged over all frames for 2 flies
% 3. images (r-theta) averaged over all frames for all flies


% first combine all images file and subsample for 
% easy access
ssdata = subsample_images();

% load the giant matrix
load('combined_data_interleaved.mat')

c = lines;


for i = 1:max(all_geno(ssdata.row_numbers))

	figure('outerposition',[0 0 1500 500],'PaperUnits','points','PaperSize',[1500 500]); hold on
	subplot(1,3,1); hold on

	for j = 1:3
		plot(all_x(all_geno==i & all_flies == j),all_y(all_geno==i & all_flies == j),'.','Color',c(j,:))
	end

	axis square
	title(geno_names{i}(1:20),'interpreter','none')
	axis off
	set(gca,'XLim',[-60 60],'YLim',[-60 60])

	% show the average image for the first fly
	subplot(1,3,2); hold on
	idx = all_geno(ssdata.row_numbers)==i & all_flies(ssdata.row_numbers) == 1;
	temp = squeeze(mean(ssdata.images(idx,:,:)));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('One fly')

	% show the average image for the all flies
	subplot(1,3,3); hold on
	idx = all_geno(ssdata.row_numbers)==i;
	temp = squeeze(mean(ssdata.images(idx,:,:)));
	imagesc(temp)
	xlabel('\Theta')
 	ylabel('R (mm)')
 	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
 	axis tight
 	title('All flies')

	prettyFig();
	

end
