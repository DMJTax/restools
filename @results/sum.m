%SUM Sum overload
%
%     S = SUM(R,DIM)
%
% Sum the entries from results object R over dimension DIM.
%
% See also: average

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function R = sum(R,dim)
if nargin<2
	dim = 1;
end

if (dim>size(R.dimnames,1))
	error('Only %d dimensions available (not %d).',size(R.dimnames,1),dim);
end

R.res = sum(R.res,dim);
R.name = [R.name,', sum over ',deblank(R.dimnames(dim,:))];
R.dim{dim} = 'sum';
%DXD: OK, I think I should not remove the dimension at all:
%	R.dimnames(dim,:) = [];

return

