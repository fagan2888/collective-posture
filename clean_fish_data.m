% clean up fish trx


trx = trx_fish;

for i = 1:length(trx)
	trx(i).x_mm = trx(i).x*10;
	trx(i).y_mm = trx(i).y*10;
end

save('Fish.mat','trx')