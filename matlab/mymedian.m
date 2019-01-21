function y = mymedian(x,dim)
%MYMEDIAN Robust median value.
%   For vectors, MYMEDIAN(X) is the median value of the elements in X.
%   For matrices, MYMEDIAN(X) is a row vector containing the median
%   value of each column.  For N-D arrays, MEDIAN(X) is the median
%   value of the elements along the first non-singleton dimension
%   of X.
%
%   MYMEDIAN(X,DIM) takes the median along the dimension DIM of X.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
if nargin==1, 
  dim = min(find(size(x)~=1)); 
  if isempty(dim), dim = 1; end
end
if isempty(x), y = []; return, end

siz = [size(x) ones(1,dim-ndims(x))];
n = size(x,dim);

% Permute and reshape so that DIM becomes the row dimension of a 2-D array
perm = [dim:max(length(size(x)),dim) 1:dim-1];
x = reshape(permute(x,perm),n,prod(siz)/n);

% Sort along first dimension
x = sort(x,1);

if rem(n,2) % Odd number of elements along DIM
  y = x((n+1)/2,:);
else % Even number of elements along DIM
  y = (x(n/2,:) + x((n/2)+1,:))/2;
end

% Check for NaNs
y(isnan(x(1,:)) | isnan(x(n,:))) = NaN;

% Permute and reshape back
siz(dim) = 1;
y = ipermute(reshape(y,siz(perm)),perm);
