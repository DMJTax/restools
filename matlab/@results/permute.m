%PERMUTE Results overload
function R = permute(R,order)

R.dimnames = R.dimnames(order,:);
R.dim = R.dim(order);
R.res = permute(R.res,order);

return
