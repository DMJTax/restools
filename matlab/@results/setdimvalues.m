%SETDIMVALUES Set the values along axes
%
%       A = SETDIMVALUES(A,DIM,VALUES)
%
% (Re)define the values along axis number DIM of results object A to
% VALUES.
% VALUES can be a (column) vector or cell-array.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setdimvalues(a,n,dim)

sz = size(a.res);
if nargin>2
	if ~isa(n,'double')
		error('Expecting a number N');
	end
	if isa(dim,'cell')
		dim = strvcat(dim);
	end
	if size(dim,1)~=sz(n)
		error('Length of DIM does not match R.res.');
	end
	a.dim{n} = dim;
else
	if size(dim,1) ~= length(sz)
		error('Number of dimension names does not fit R.res .');
	end
	a.dim = dim;
end

return
