% this script converts the giant matrix
% made by make_giant_matrix
% into a set of "images" of egocentric positions 

clearvars

% load the giant matrix
load('combined_data_interleaved.mat')


% some global parameters
r_max = 40; % mm, the distance to go out from each fly 

sub_sample_ratio = 10;
r_n_bins = 20;
theta_n_bins = 30;

R_bin_edges = linspace(0,r_max,r_n_bins*sub_sample_ratio+1);
theta_bin_edges = linspace(0,2*pi,theta_n_bins*sub_sample_ratio+1);

all_images = zeros(1e6,r_n_bins+1,theta_n_bins+1);
row_numbers = NaN(1e6,1);


% make the Gaussian kernel
sigma_r = 5; % in units of high-res matrix
sigma_theta = 5;

N = sigma_r*5;
M = sigma_theta*5;
[x y]=meshgrid(round(-N/2):round(N/2), round(-M/2):round(M/2));
GK=exp(-x.^2/(2*sigma_r^2)-y.^2/(2*sigma_theta^2));
GK = GK';
GK=GK./sum(GK(:));
GK_width_r = floor(size(GK,1)/2);
GK_width_theta = floor(size(GK,2)/2);


X = zeros(length(R_bin_edges)+size(GK,1),length(theta_bin_edges)+size(GK,2));


% optim param
search_window = 30; % should be larger than the # of flies


% define rotation matrix
R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];


% make a vector for the closest fly in each row
closest_fly_dist = NaN*all_x;

idx = 1;
file_idx = 1;


% temp -- for dev. do only on part of data
%all_x = all_x(all_geno<6);
N = length(all_x);


for i = 1:length(all_x)

	if rand > .9999
		disp((i/length(all_x))*100)
	end

	a = max([i-search_window,1]);
	z = min([i+search_window,N]);

	% restrict search to neighbourhood in
	% giant matrix
	search_x = all_x(a:z);
	search_y = all_y(a:z);
	search_flies = all_flies(a:z);
	search_frames = all_frames(a:z);
	search_geno = all_geno(a:z);
	search_theta = all_theta(a:z);

	% find all other flies 
	% in this frame

	look_here = search_flies ~= all_flies(i) & search_frames == all_frames(i);
	other_x = search_x(look_here);
	other_y = search_y(look_here);

	% find distances to all other flies in frame 
	D = sqrt((other_x - all_x(i)).^2 + (other_y - all_y(i)).^2);


	% coordinate transform -- center origin on this fly
	other_x = other_x(D<r_max) - all_x(i);
	other_y = other_y(D<r_max) - all_y(i);
	closest_fly_dist(i) = min(D);

	% coordinate transform -- rotate axes
	temp = R(-all_theta(i))*[other_x other_y]';
	other_x = temp(1,:);
	other_y = temp(2,:);

	[theta,rho] = cart2pol(other_x,other_y);
	theta = mod(theta,2*pi);

	if isempty(rho)
		continue
	end

	

	% discretize rho and theta
	rho = floor((rho/r_max)*length(R_bin_edges-1)) + GK_width_r;
	theta = floor((theta/(2*pi))*length(theta_bin_edges-1)) + GK_width_theta;

	% drop Gaussians where there should be points

	X = X*0;
	for j = 1:length(rho)
		r_a = rho(j) - GK_width_r+1;
		r_z = rho(j) + GK_width_r+1;
		theta_a = theta(j) - GK_width_theta+1;
		theta_z = theta(j) + GK_width_theta+1;
		X(r_a:r_z,theta_a:theta_z) = X(r_a:r_z,theta_a:theta_z) + GK;
	end

	% cut in R dimension, wrap in theta dimension
	XX = X;

	XX=XX(GK_width_r+1:end-GK_width_r-1,:);
	XX_theta_left = XX(:,1:GK_width_theta+1);
	XX_theta_right = XX(:,end-GK_width_theta:end);
	XX = XX(:,GK_width_theta+2:end-GK_width_theta);
	XX(:,1:GK_width_theta+1) = XX(:,1:GK_width_theta+1) + XX_theta_right;
	XX(:,end-GK_width_theta:end) = XX(:,end-GK_width_theta:end) + XX_theta_left;


	
	if file_idx < all_geno(i)
		
		disp('Saving...')

		all_images = all_images(1:idx-1,:,:);
		row_numbers = row_numbers(1:idx-1);
		save(['all_images' mat2str(file_idx) '.mat'],'all_images','row_numbers','-v7.3')
		
		all_images = zeros(1e6,r_n_bins+1,theta_n_bins+1);
		row_numbers = NaN(1e6,1);

		file_idx = all_geno(i);
		idx = 1;
	end


	all_images(idx,:,:) = XX(1:sub_sample_ratio:end,1:sub_sample_ratio:end);
	row_numbers(idx) = i;
	idx = idx + 1;




end

