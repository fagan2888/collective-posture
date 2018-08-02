% make egocentric images
% this function works on the raw trx files 
% from Kristin Branson and converts them into giant
% matrices of egocentric images

function make_egocentric_images(varargin)

% options and defaults
options.r_max = 10; % body length
options.sub_sample_ratio = 5;
options.r_n_bins = 40;
options.theta_n_bins = 40;
options.sigma_r = 5; % in units of high-res matrix
options.sigma_theta = 5;
options.trx_folder = '~/Desktop/fly_trx';
options.t_bin_size = 1000; % frames
options.t_bin_step = 1000; % frames
options.recompute_ego = true;

if nargout && ~nargin 
	varargout{1} = options;
    return
end

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options.(temp) = varargin{ii+1};
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end





geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};


for i = 1:5

	disp([options.trx_folder filesep geno_names{i}])

	if exist([geno_names{i} '.rtheta'],'file') ~= 2

		
		load([options.trx_folder filesep geno_names{i}])
		
		traj_lengths = cellfun(@length,{trx.x});
		rm_this = traj_lengths ~= mode(traj_lengths);

		trx(rm_this) = [];
		x = vertcat(trx.x_mm);
		y = vertcat(trx.y_mm);
		all_theta = vertcat(trx.theta);

		makeRThetaMatrix(x,y,all_theta,geno_names{i},options);
	else
		disp('R-theta representation exists. loading that...')
		
	end

	load([geno_names{i} '.rtheta'],'-mat')

	if any(strfind(geno_names{i},'ctrax'))
		% it's a fly
		R = R/2; % assuming body length of 2 mm
	else
		error('not a fly, dont know what to do')
	end


	if exist([geno_names{i} '.ego'],'file') ~= 2 

		binRTheta(R,T,geno_names{i},options);
	else
		if options.recompute_ego
			binRTheta(R,T,geno_names{i},options);
		else
			disp('.ego file exists, not recomputing')
		end
	end

end


