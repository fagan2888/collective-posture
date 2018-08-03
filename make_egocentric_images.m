% make egocentric images
% this function works on the raw trx files 
% from Kristin Branson and converts them into giant
% matrices of egocentric images

function make_egocentric_images(varargin)

% options and defaults
options.r_max = 20; % body length
options.sub_sample_ratio = 5;
options.r_n_bins = 40;
options.theta_n_bins = 20;
options.sigma_r = 5; % in units of high-res matrix
options.sigma_theta = 5;
options.trx_folder = '~/Desktop/fly_trx';
options.t_bin_size = 1e3; % frames
options.t_bin_step = 1e3; % frames
options.recompute_ego = false;

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


parfor i = 1:length(geno_names)

	parallelWorker(geno_names{i},options)

end


