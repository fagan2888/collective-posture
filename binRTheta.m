% this function actually makes the images
% from the x and y and theta info

function binRTheta(all_R,all_theta,geno_name,options)


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

n_flies = size(all_R,2);
n_frames = size(all_R,1);


look_at_these_frames = 1:options.t_bin_step:(n_frames - options.t_bin_size-1);

n_images = length(look_at_these_frames);

all_images = zeros(n_flies,n_images,options.r_n_bins+1,options.theta_n_bins+1);
n_neighbours = zeros(n_images,n_flies);


for i = 1:n_flies


	textbar(i,n_flies)

	for j = 1:n_images


		frame = look_at_these_frames(j);

		this_r = vectorise(squeeze(all_R(frame:frame+options.t_bin_size,i,:)));
		this_theta = vectorise(squeeze(all_theta(frame:frame+options.t_bin_size,i,:)));

		rm_this = this_r > options.r_max;
		this_r(rm_this) = [];
		this_theta(rm_this) = [];
		this_theta = mod(this_theta,2*pi);

		% discretize rho and theta
		rho = floor((this_r/options.r_max)*length(R_bin_edges-1)) + GK_width_r;
		theta = floor((this_theta/(2*pi))*length(theta_bin_edges-1)) + GK_width_theta;

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

		XX = XX(GK_width_r+1:end-GK_width_r-1,:);
		XX_theta_left = XX(:,1:GK_width_theta+1);
		XX_theta_right = XX(:,end-GK_width_theta:end);
		XX = XX(:,GK_width_theta+2:end-GK_width_theta);
		XX(:,1:GK_width_theta+1) = XX(:,1:GK_width_theta+1) + XX_theta_right;
		XX(:,end-GK_width_theta:end) = XX(:,end-GK_width_theta:end) + XX_theta_left;


		% subsample
		all_images(i,j,:,:) = XX(1:options.sub_sample_ratio:end,1:options.sub_sample_ratio:end);
		n_neighbours(i,j) = length(rho);


	end

end

% save this

sz = size(all_images);
all_images =  reshape(all_images,sz(1)*sz(2),sz(3),sz(4));
fly_id = vectorise(repmat(1:n_flies,1,n_images));
frame_ids = vectorise(repmat(look_at_these_frames,n_flies,1));

save([geno_name,'.ego'],'all_images','frame_ids','fly_id')

