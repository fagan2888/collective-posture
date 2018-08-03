% clean up fish trx


n_frames = min(cellfun(@length,{trx.x}));

for i = 1:length(trx)

	trx(i).x = trx(i).x(1:n_frames);
	trx(i).y = trx(i).y(1:n_frames);
	trx(i).theta = trx(i).theta(1:n_frames);

	trx(i).x_mm = trx(i).x*10;
	trx(i).y_mm = trx(i).y*10;
end

save('~/Desktop/Fish_Guppies.mat','trx')