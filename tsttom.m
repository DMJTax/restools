nrfolds = 10;
r = [zeros(1,nrfolds); 0.2*ones(1,nrfolds)] + 0.1*randn(2,nrfolds);
r = r + repmat((1:nrfolds)/10,2,1);

R = results(r,2,nrfolds);
show(average(R,2,'max1','indep'))
show(average(R,2,'max1','dep'))
