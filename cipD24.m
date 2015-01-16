function cipD24(alpha, run)

pshare = 10.^(-5:0.5:-2);

clear stats;

%matlabpool 2

parfor i=1:length(pshare)

stats(i) = parD24(pshare(i), alpha, 13+run*7);

end

save(['D24_sim1_alpha' num2str(alpha) '_run' num2str(run) '.mat'], 'stats')

%matlabpool close
