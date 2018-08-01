% this function actually makes the images
% from the x and y and theta info

function makeECIEngine(all_x,all_y,all_theta,geno_name,options)


R_bin_edges = linspace(0,options.r_max,options.r_n_bins*options.sub_sample_ratio+1);
theta_bin_edges = linspace(0,2*pi,options.theta_n_bins*options.sub_sample_ratio+1);


% make the Gaussian kernel
N = options.sigma_r*5;
M = options.sigma_theta*5;
[x y]=meshgrid(round(-N/2):round(N/2), round(-M/2):round(M/2));
GK=exp(-x.^2/(2*options.sigma_r^2)-y.^2/(2*options.sigma_theta^2));
GK = GK';
GK=GK./sum(GK(:));
GK_width_r = floor(size(GK,1)/2);
GK_width_theta = floor(size(GK,2)/2);


% this matrix stores the "high res" image
X = zeros(length(R_bin_edges)+size(GK,1),length(theta_bin_edges)+size(GK,2));

% define rotation matrix
R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];

n_flies = size(all_x,1);
n_frames = size(all_x,2);


all_images = zeros(n_frames,n_flies,options.r_n_bins+1,options.theta_n_bins+1);
n_neighbours = zeros(n_frames,n_flies);



parfor j = 1:n_frames



	for k = 1:n_flies

		% find the positions of all other flies
		other_x = all_x(:,j);
		other_y = all_y(:,j);

		% coordinate transform -- remove origin
		other_x = other_x - all_x(k,j);
		other_y = other_y - all_y(k,j);

		% find distances to all other flies in frame 
		D = sqrt(other_x.^2 + other_y.^2);
		rm_this = D == 0 | D > options.r_max;

		other_x(rm_this) = [];
		other_y(rm_this) = [];

		if isempty(other_y)
			continue
		end

		% coordinate transform -- rotate axes
		temp = R(-all_theta(k,j))*[other_x other_y]';


		other_x = temp(1,:);
		other_y = temp(2,:);

		% convert to polar
		[theta,rho] = cart2pol(other_x,other_y);
		theta = mod(theta,2*pi);


		% discretize and put into matrix
		% (this step also blurs)

		% discretize rho and theta
		rho = floor((rho/options.r_max)*length(R_bin_edges-1)) + GK_width_r;
		theta = floor((theta/(2*pi))*length(theta_bin_edges-1)) + GK_width_theta;

		% drop Gaussians where there should be points

		% this matrix stores the "high res" image
		X = zeros(length(R_bin_edges)+size(GK,1),length(theta_bin_edges)+size(GK,2));

		for l = 1:length(rho)
			r_a = rho(l) - GK_width_r+1;
			r_z = rho(l) + GK_width_r+1;
			theta_a = theta(l) - GK_width_theta+1;
			theta_z = theta(l) + GK_width_theta+1;
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


		% subsample

		all_images(j,k,:,:) = XX(1:options.sub_sample_ratio:end,1:options.sub_sample_ratio:end);
		n_neighbours(j,k) = length(other_y);

	end

end

sz = size(all_images);
all_images =  reshape(all_images,sz(1)*sz(2),sz(3),sz(4));
sz = size(n_neighbours);
n_neighbours = reshape(n_neighbours,sz(1)*sz(2),1);
fly_id = vectorise(repmat(1:n_flies,n_frames,1));

save([geno_name,'.ego'],'all_images','n_neighbours','fly_id')
