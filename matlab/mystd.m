function s = mystd(x,flag,dim)
%MYSTD Robust standard deviation
%
%        S = MYSTD(X,FLAG,DIM)
%
% Compute the standard deviation of matrix X, along dimension DIM,
% ignorming the presence of NaNs. When FLAG is set, the standard
% deviation is normalized by N, and not by N-1.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherland

if nargin<3
	dim = 1;
end
if nargin<2
	flag = 0;
end

% Find the mean:
m = mymean(x,dim);

% Remove the mean:
sz = size(x);
reps = ones(1,length(sz));
reps(dim) = sz(dim);
x = x-repmat(m,reps);

% Square the differences:
x2 = x.*x;
% Find the nans:
%nans = isnan(x2);
nans = ~isfinite(x2);
% Set the nan-values to 0 (so they are ignored in the mean):
x2(nans) = 0;
% Sum over the right dimension:
warning off MATLAB:divideByZero;
if flag
	s = sum(x2,dim) ./ sum(1-nans,dim);
else
	s = sum(x2,dim) ./ (sum(1-nans,dim)-1);
	% special case for dimensions with a single value:
	s(sum(1-nans,dim)==1) = 0;
end
warning on MATLAB:divideByZero;

s = sqrt(s);

return

