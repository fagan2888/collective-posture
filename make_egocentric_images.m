% make egocentric images
% this function works on the raw trx files 
% from Kristin Branson and converts them into giant
% matrices of egocentric images

function make_egocentric_images(varargin)

% get options from dependencies 
options = getOptionsFromDeps(mfilename);

% options and defaults
options.use_parallel = true;
options.r_max = 40; % mm
options.sub_sample_ratio = 10;
options.r_n_bins = 20;
options.theta_n_bins = 30;
options.sigma_r = 5; % in units of high-res matrix
options.sigma_theta = 5;
options.search_window = 30; % should be larger than the # of flies
options.trx_folder = '~/Desktop/fly-trx';

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

% make placeholders for variables
x = zeros(20,20e5);
y = zeros(20,20e5);
all_theta = zeros(20,20e5);
n_flies = 20;



for i = 5

	disp([options.trx_folder filesep geno_names{i}])
	load([options.trx_folder filesep geno_names{i}])
	x = vertcat(trx.x_mm);
	y = vertcat(trx.y_mm);
	all_theta = vertcat(trx.theta);


	makeECIEngine(x,y,all_theta,geno_names{i},options);
end


