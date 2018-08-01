% this function is designed to work on the trx
% and convert them into egocentric co-ordinates
% there are no parameters here, so this is expected
% to be run only once

function makeRThetaMatrix(all_x,all_y,all_theta,geno_name,options)


% define rotation matrix
RotMat = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];

n_flies = size(all_x,1);
n_frames = size(all_x,2);

T = zeros(n_frames,n_flies,n_flies-1);
R = zeros(n_frames,n_flies,n_flies-1);



parfor j = 1:n_frames


	for k = 1:n_flies

		% find the positions of all other flies
		other_x = all_x(:,j);
		other_y = all_y(:,j);

		% coordinate transform -- remove origin
		other_x = other_x - all_x(k,j);
		other_y = other_y - all_y(k,j);


		% coordinate transform -- rotate axes
		temp = RotMat(-all_theta(k,j))*[other_x other_y]';


		other_x = temp(1,:);
		other_y = temp(2,:);

		% convert to polar
		[theta,rho] = cart2pol(other_x,other_y);
		theta = mod(theta,2*pi);

		theta(rho==0) = [];
		rho(rho==0) = [];

		T(j,k,:) = theta(1:n_flies-1);
		R(j,k,:) = rho(1:n_flies-1);

	end

end

save([geno_name,'.rtheta'],'R','T')
