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

% load all images and subsample to keep them all in memory

load('combined_data_interleaved.mat')

clear smoothed_data
smoothed_data.images = zeros(1e6,21,31);
smoothed_data.fly_id = NaN(1e6,1);
smoothed_data.geno_id = NaN(1e6,1);


idx = 1;
all_files = dir('all_images*.mat');




for i = 1:length(all_files)
	disp(i)

	clear all_images row_numbers
	load((all_files(i).name));

	n_flies = max(all_flies(row_numbers));

	for j = 1:n_flies
		this_fly = all_flies(row_numbers) == j;

		this_fly_images = all_images(this_fly,:,:);
		step_size = floor(size(this_fly_images,1)/nchunks);
		this_fly_images = this_fly_images(1:step_size*nchunks,:,:);
		sz = size(this_fly_images);
		this_fly_images = reshape(this_fly_images,sz(1)/nchunks,nchunks,sz(2),sz(3));
		this_fly_images = squeeze(mean(this_fly_images,1));


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
	smoothed_data.geno_id = smoothed_data.geno_id(1:z-1);
end

save('smoothed_data.mat','smoothed_data','-v7.3')
