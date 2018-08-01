% this script mashes together
% all images from all flies
% from all datasets into a one matrix
% and fits it into memory by smoothing 
% over time
% nchunks is the number of chunks you want
% to split each trajectory into 

function smoothed_data = smooth_images(nchunks)

if exist('smoothed_data.mat','file') == 2
	disp('loading pre-computed smoothed_data')
	load('smoothed_data')
	return
end


clear smoothed_data
smoothed_data.images = zeros(1e6,21,31);
smoothed_data.fly_id = NaN(1e6,1);
smoothed_data.geno_id = NaN(1e6,1);
smoothed_data.frame_id = NaN(1e6,1);
smoothed_data.n_neighbours = NaN(1e6,1);


idx = 1;
all_files = dir('*.ego');



for i = 1:length(all_files)
	disp(i)

	clear all_images row_numbers
	load((all_files(i).name),'-mat');

	n_flies = max(fly_id);

	for j = 1:n_flies
		this_fly = fly_id == j;

		this_fly_images = all_images(this_fly,:,:);
		step_size = floor(size(this_fly_images,1)/nchunks);
		this_fly_images = this_fly_images(1:step_size*nchunks,:,:);
		sz = size(this_fly_images);
		this_fly_images = reshape(this_fly_images,sz(1)/nchunks,nchunks,sz(2),sz(3));
		this_fly_images = squeeze(mean(this_fly_images,1));

		this_n_neighbours = n_neighbours(1:step_size*nchunks);
		sz = size(this_n_neighbours);
		this_n_neighbours = reshape(this_n_neighbours,sz(1)/nchunks,nchunks);
		this_n_neighbours = squeeze(mean(this_n_neighbours,1));

		smoothed_data.frame_id(idx:idx+nchunks-1) = round(linspace(1,length(find(this_fly)),nchunks));
		smoothed_data.n_neighbours(idx:idx+nchunks-1) = this_n_neighbours;
		smoothed_data.images(idx:idx+nchunks-1,:,:) = this_fly_images;
		smoothed_data.fly_id(idx:idx+nchunks-1) = j;
		smoothed_data.geno_id(idx:idx+nchunks-1) = i;

		idx = idx + nchunks;

	end


end

z = find(isnan(smoothed_data.fly_id),1,'first');
if ~isempty(z)
	smoothed_data.images = smoothed_data.images(1:z-1,:,:);
	smoothed_data.fly_id = smoothed_data.fly_id(1:z-1);
	smoothed_data.n_neighbours = smoothed_data.n_neighbours(1:z-1);
	smoothed_data.frame_id = smoothed_data.frame_id(1:z-1);
	smoothed_data.geno_id = smoothed_data.geno_id(1:z-1);
end

save('smoothed_data.mat','smoothed_data','-v7.3')
