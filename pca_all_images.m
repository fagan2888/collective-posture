% this script performs PCA
% on the giant image matrix
% that is too big to fit in memory
% it does so by picking a subset 
% of the data, and then PCA-ing that
% and then using those Eigenvectors 
% to compute the weights of each image


% load all images into one matrix
all_files = dir('*.ego');

load(all_files(1).name,'-mat')
images = all_images;
all_fly_id = fly_id;
all_frames = frame_ids;
all_geno = 0*(1:length(all_fly_id)) + 1;
all_geno = all_geno(:);

for i = 2:length(all_files)
	load(all_files(i).name,'-mat')

	images = vertcat(images, all_images);
	all_fly_id = vertcat(all_fly_id,fly_id);
	all_frames = vertcat(all_frames,frame_ids);
	all_geno = vertcat(all_geno,ones(length(fly_id),1)*i);
end



sz = size(images);
reshaped_images = reshape(images,sz(1),sz(2)*sz(3));

[coeff,score,latent,tsquared,explained,mu] = pca(reshaped_images);


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

% t-SNE the top 200 modes
X = score(:,1:200);


R = mctsne(X');

% plot and color by genotype
figure('outerposition',[0 0 600 600],'PaperUnits','points','PaperSize',[600 600]); hold on
labels = all_geno;

c = lines(max(labels)+1);

for i = 1:max(labels)
	cla
	plot(R(1,:),R(2,:),'.','Color',[.5 .5 .5])

	plot(R(1,labels==i),R(2,labels==i),'.','Color',c(i,:),'MarkerSize',24)
	pause(2)
end



return


% pre-load all the trx
options.trx_folder = '~/Desktop/fly-trx';
geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};


global all_trx
trx = struct;
all_trx = struct;
disp('Loading trx...')
for i = 1:length(geno_names)
    textbar(i,length(geno_names))
    load([options.trx_folder filesep geno_names{i}],'trx')
    all_trx(i).trx = trx;
end



% launch t-SNE explorer
exploreTSNE(R,all_geno,images)




% plot and color by # of neighbours

% figure('outerposition',[0 0 600 600],'PaperUnits','points','PaperSize',[600 600]); hold on
% labels = round(ssdata.n_neighbours);

% c = parula(max(labels)+1);
% plot(R(1,:),R(2,:),'.','Color',[.5 .5 .5])
% for i = 1:max(labels)

% 	plot(R(1,labels==i),R(2,labels==i),'.','Color',c(i,:),'MarkerSize',24)

% end




return


