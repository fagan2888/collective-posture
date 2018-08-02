% this script sets up things for 
% interactively exploring the t-SNE 
% embedding using exploreTSNE
% 
% run this after running pca_all_images

assert(exist('x_plot','var') == 1,'x_plot does not exist. run pca_all_images first')
assert(exist('y_plot','var') == 1,'y_plot does not exist. run pca_all_images first')
assert(exist('D','var') == 1,'D does not exist. run pca_all_images first')
assert(exist('images','var') == 1,'images does not exist. run pca_all_images first')

tsne_data.x = x_plot;
tsne_data.y = y_plot;
tsne_data.D = D;
tsne_data.images = images;
tsne_data.all_geno = all_geno;
tsne_data.all_frames = all_frames;
tsne_data.all_fly_id = all_fly_id;

load('saved_colormaps.mat')
tsne_data.cc = cc;

options.trx_folder = '~/Desktop/fly_trx';

if ~exist('all_trx','var')

	% pre-load all the trx

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
	tsne_data.all_trx = all_trx;
end



% launch t-SNE explorer
exploreTSNE(tsne_data)

