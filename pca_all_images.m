% this script performs PCA
% on the giant image matrix
% that is too big to fit in memory
% it does so by picking a subset 
% of the data, and then PCA-ing that
% and then using those Eigenvectors 
% to compute the weights of each image


% first combine all images file and subsample for 
% easy access

ssdata = smooth_images(10);


sz = size(ssdata.images);
images = ssdata.images;
ssdata.images = reshape(ssdata.images,sz(1),sz(2)*sz(3));

[coeff,score,latent,tsquared,explained,mu] = pca(ssdata.images(:,:,:));


figure('outerposition',[0 0 800 801],'PaperUnits','points','PaperSize',[800 801]); hold on

% show the first 3 PCs
for i = 1:3
	subplot(2,2,i); hold on
	imagesc(reshape(coeff(:,i),sz(2),sz(3)))
	xlabel('\Theta')
	ylabel('R (mm)')
	set(gca,'XTick',[0, 7.5, 15, 22.5,30], 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
	axis tight
	title(['PC#' mat2str(i)])
end

subplot(2,2,4); hold on
plot(cumsum(explained),'k')
xlabel('PC#')
ylabel('Cumulative variance explained')
plot([200 200],[0 100],'k--')


prettyFig();

box off




R = mctsne(ssdata.images');


% launch t-SNE explorer

exploreTSNE(R,ssdata.geno_id,images)




% plot and color by # of neighbours

% figure('outerposition',[0 0 600 600],'PaperUnits','points','PaperSize',[600 600]); hold on
% labels = round(ssdata.n_neighbours);

% c = parula(max(labels)+1);
% plot(R(1,:),R(2,:),'.','Color',[.5 .5 .5])
% for i = 1:max(labels)

% 	plot(R(1,labels==i),R(2,labels==i),'.','Color',c(i,:),'MarkerSize',24)

% end



% % plot and color by genotype
% figure('outerposition',[0 0 600 600],'PaperUnits','points','PaperSize',[600 600]); hold on
% labels = ssdata.geno_id;

% c = lines(max(labels)+1);

% for i = 1:max(labels)
% 	cla
% 	plot(R(1,:),R(2,:),'.','Color',[.5 .5 .5])

% 	plot(R(1,labels==i),R(2,labels==i),'.','Color',c(i,:),'MarkerSize',24)
% 	pause(2)
% end

return


