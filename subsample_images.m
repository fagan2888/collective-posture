% this script mashes together
% all images from all flies
% from all datasets into a one matrix
% and fits it into memory by subsampling 

function subsampled_data = subsample_images()

if exist('subsampled_data.mat','file') == 2
	disp('loading pre-computed subsampled_data')
	load('subsampled_data')
	return
end

clearvars
% load all images and subsample to keep them all in memory

clear subsampled_data
subsampled_data.images = zeros(1e6,21,31);
subsampled_data.row_numbers = NaN(1e6,1);
idx = 1;
all_files = dir('all_images*.mat');




for i = 1:length(all_files)
	disp(i)
	load((all_files(i).name));

	data_size = length(all_images(1:100:end,:,:));
	subsampled_data.images(idx:idx+data_size-1,:,:) = all_images(1:100:end,:,:);
	subsampled_data.row_numbers(idx:idx+data_size-1) = row_numbers(1:100:end,1);
	idx = find(isnan(subsampled_data.row_numbers),1,'first');
end

z = find(isnan(subsampled_data.row_numbers),1,'first');
if ~isempty(z)
	subsampled_data.images = subsampled_data.images(1:z-1,:,:);
	subsampled_data.row_numbers = subsampled_data.row_numbers(1:z-1);
end

save('subsampled_data.mat','subsampled_data','-v7.3')
