% this script converts the data that KB gave us 
% into a giant 2D matrix that we can use more easily
% the idea is to aggregate all the data we need
% into a single .mat file so we can work with it 
% more easily, while preserving (some) metadata

root_name = '~/Desktop/fly-trx';


geno_names = dir([root_name filesep '*.mat']);
geno_names = {geno_names.name};


N = 1e6;
all_geno = NaN(N,1);
all_flies = NaN(N,1);
all_x = NaN(N,1);
all_y = NaN(N,1);
all_theta = NaN(N,1);
all_sex = NaN(N,1);
all_frames = NaN(N,1);


idx = 1;

for i = 1:length(geno_names)
	disp(geno_names{i})
	clear trx
	load([root_name filesep geno_names{i}])
	ok_flies = true(length(trx),1);
	for j = 2:length(trx)
		if length(trx(j).x_mm) ~= length(trx(1).x_mm)
			ok_flies(j) = false;
		end
	end
	trx = trx(ok_flies);
	disp(['This file has ' mat2str(length(trx)) ' flies of data'])

	if length(trx) < 10
		continue
	end


	this_x = vectorise(vertcat(trx.x_mm));
	this_y = vectorise(vertcat(trx.y_mm));
	this_theta = vectorise(vertcat(trx.theta));

	this_flies = (repmat(1:length(trx),1,length(trx(1).x_mm)));

	data_size = length(this_x);
	
	all_x(idx:idx-1+data_size) = this_x;
	all_y(idx:idx-1+data_size) = this_y;
	all_theta(idx:idx-1+data_size) = this_theta;

	all_flies(idx:idx-1+data_size) = this_flies;
	all_geno(idx:idx-1+data_size) = i;

	this_sex = NaN(length(trx),1);
	for j = 1:length(trx)
		if strcmp(trx(j).sex{1},'M')
			this_sex(j) = 1;
		else
			this_sex(j) = 0;
		end
	end

	this_sex = (repmat(this_sex,1,length(trx(1).x_mm)));


	all_sex(idx:idx-1+data_size) = this_sex;
	all_frames(idx:idx-1+data_size) = vectorise((repmat(1:length(trx(1).x_mm),length(trx),1)));


	idx = idx + data_size;

end



save('combined_data_interleaved.mat','all_x','all_y','all_geno','all_flies','all_theta','geno_names','all_frames','all_sex')