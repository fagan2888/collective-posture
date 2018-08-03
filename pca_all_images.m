% this script PCAs all the images 
% and then t-SNEs the top N modes

close all

% load all images into one matrix
all_files = dir('*.ego');

load(all_files(1).name,'-mat')
images = all_images;
all_fly_id = fly_id;
all_frames = frame_ids;
all_geno = 0*(1:length(all_fly_id)) + 1;
all_geno = all_geno(:);

for i = 2:length(all_files)
	textbar(i,length(all_files))
	load(all_files(i).name,'-mat')

	images = vertcat(images, all_images);
	all_fly_id = vertcat(all_fly_id,fly_id);
	all_frames = vertcat(all_frames,frame_ids);
	all_geno = vertcat(all_geno,ones(length(fly_id),1)*i);
end



sz = size(images);
reshaped_images = reshape(images,sz(1),sz(2)*sz(3));

[coeff,score,latent,tsquared,explained,mu] = pca(reshaped_images);


figure('outerposition',[0 0 1200 801],'PaperUnits','points','PaperSize',[1200 801]); hold on

% show the first 5 PCs
for i = 1:5
	subplot(2,3,i); hold on
	temp = reshape(coeff(:,i),sz(2),sz(3));
	imagesc(temp)
	xlabel('\Theta')
	ylabel('R (a.u.)')
	set(gca,'XTick',linspace(1,size(temp,2),5), 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})
	axis tight
	title(['PC#' mat2str(i)])
end


n_modes = find(cumsum(explained) > 90,1,'first');
disp([mat2str(n_modes) ' modes capture 90% of the variance'])
X = score(:,1:n_modes);

subplot(2,3,6); hold on
plot(cumsum(explained),'k')
xlabel('PC#')
ylabel('Cumulative variance explained')
plot([n_modes n_modes],[0 100],'k--')
set(gca,'XScale','log','XLim',[1 1e3])


prettyFig();
box off



R = mctsne(X');


% estimate a density by convolving with gaussians 
figure('outerposition',[0 0 700 700],'PaperUnits','points','PaperSize',[700 700]); hold on

N = 200;
D = zeros(N+1,N+1);
x = R(1,:);
y = R(2,:);
x = x - min(x);  y = y - min(y); 
x = x/max(x); y= y/max(y);
x_plot = x*N; y_plot = y*N;

x = floor(x*N)+1; y = floor(y*N)+1;
for i = 1:length(x)
	D(x(i),y(i)) = D(x(i),y(i)) + 1;
end

% remove some junk
D(D>14) = 0;
D = imgaussfilt(D,3);
h = imagesc(D);
load('saved_colormaps.mat')
colormap(cc)
axis square
axis tight
axis off
prettyFig();

return


% plot and color by genotype
figure('outerposition',[0 0 500 500],'PaperUnits','points','PaperSize',[1000 500]); hold on

labels = all_geno;

t = title('genotype','interpreter','none');
plot(R(1,:),R(2,:),'.','Color',[1 1 1]*.6,'MarkerSize',5)
h = plot(NaN,NaN,'k.','MarkerSize',20)
axis square
c = lines(100);
for i = 1:max(labels)

	t.String = [mat2str(i) flstring(all_files(i).name,20)];

	h.XData = R(1,labels==i);
	h.YData = R(2,labels==i);
	h.Color = c(i,:);
	pause(2)
end

return

% show some genotypes
geno_names = {all_files.name};
show_these = [1 8 11 13 16 18 19 21 26 28 42 56];

figure('outerposition',[0 0 1401 800],'PaperUnits','points','PaperSize',[1401 800]); hold on
c = lines;
for i = 12:-1:1
	subplot(3,4,i); hold on
	plot(R(1,1:10:end),R(2,1:10:end),'.','Color',[1 1 1]*.6,'MarkerSize',5)
	this_geno = show_these(i);
	plot(R(1,all_geno == this_geno),R(2,all_geno == this_geno),'.','Color',c(i,:),'MarkerSize',20)
	if i > 1
		title([geno_names{this_geno}(1:20)],'interpreter','none')
	else
		title('Fish!')
	end
	axis off
end

prettyFig();








