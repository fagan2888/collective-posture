% find all *.mat file 

root_dir = '/Volumes/Angela/all_flies/';
allfiles = getAllFiles(root_dir);

for i = 1:length(allfiles)

	if strcmp(pathEnd(allfiles{i}),'ctrax_results')
		disp(allfiles{i})


		clear trx
		load(allfiles{i})

		geno =  strsplit(trx(1).moviename,'/');
		geno = geno{end-1};

		save(['~/Desktop/fly-trx/' geno '.mat'],'trx')

	end

end