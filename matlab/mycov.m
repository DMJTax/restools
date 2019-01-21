function s = mycov(x)
%MYCOV Robust covariance matrix
%
%        S = MYCOV(X)
%
% Compute the covariance matrix of matrix X ignoring NaN's.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherland

[N,dim] = size(x);

% Find the mean:
m = mymean(x,1);

% Remove the mean:
x = x-repmat(m,N,1);

% Replace all the NaN's by zeros, so it will dissappear
% from the inner products:
nans = isnan(x);
x(nans) = 0;

% now make the cov matrix:
s = cov(x);

return

