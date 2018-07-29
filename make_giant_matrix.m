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


idx = 1;

for i = 1:length(geno_names)
	disp(geno_names{i})
	clear trx
	load([root_name filesep geno_names{i}])

	for j = 1:length(trx)
		data_size = length(trx(j).x);
		all_x(idx:idx-1+data_size) = trx(j).x;
		all_y(idx:idx-1+data_size) = trx(j).y;
		all_theta(idx:idx-1+data_size) = trx(j).theta;
		all_flies(idx:idx-1+data_size) = j;
		all_geno(idx:idx-1+data_size) = i;

		idx = idx + data_size;

	end


end



save('combined_data.mat','all_x','all_x','all_geno','all_flies','all_theta','geno_names')