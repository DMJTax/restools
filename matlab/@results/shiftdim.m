%SHIFTDIM Results overload
function R = shiftdim(R,n)

nrdim = size(R.dimnames,1);
I = circshift((1:nrdim)',n);
R.dimnames = R.dimnames(I,:);
R.dim = R.dim(I);
R.res = shiftdim(R.res,nrdim-n);

return
