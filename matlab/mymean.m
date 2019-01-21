function m = mynanmean(x,dim)
%MYMEAN Compute the mean, ignoring NaN's
%
%     M = MYMEAN(X,DIM)
%
% Compute the mean of matrix X, along dimension DIM, ignoring the
% presence of NaN's.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherland

if nargin<2
	dim = 1;
end

% Find the NaNs
%nans = isnan(x);
nans = ~isfinite(x);
% Set the nan-values to 0 (so they are ignored in the mean):
x(nans) = 0;
% Sum over the right dimension:
warning off MATLAB:divideByZero;
m = sum(x,dim) ./ sum(1-nans,dim);
warning on MATLAB:divideByZero;

return

