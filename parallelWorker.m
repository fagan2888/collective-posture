function parallelWorker(geno_name, options)

disp([options.trx_folder filesep geno_name])

if exist([geno_name '.rtheta'],'file') ~= 2

	
	load([options.trx_folder filesep geno_name],'trx')
	
	traj_lengths = cellfun(@length,{trx.x});
	rm_this = traj_lengths ~= mode(traj_lengths);

	trx(rm_this) = [];
	x = vertcat(trx.x_mm);
	y = vertcat(trx.y_mm);
	all_theta = vertcat(trx.theta);

	makeRThetaMatrix(x,y,all_theta,geno_name,options);
else
	disp('R-theta representation exists. loading that...')
	
end

load([geno_name '.rtheta'],'-mat')

if any(strfind(geno_name,'ctrax'))
	% it's a fly
	R = R/2; % assuming body length of 2 mm
elseif any(strfind(geno_name,'Sunbleak'))
	% fish size is 40 mm
	R = R/40;
else
	% guppies
	R = R/30;
end


if exist([geno_name '.ego'],'file') ~= 2 

	binRTheta(R,T,geno_name,options);
else
	if options.recompute_ego
		binRTheta(R,T,geno_name,options);
	else
		disp('.ego file exists, not recomputing')
	end
end