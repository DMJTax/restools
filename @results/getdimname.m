%GETDIMNAME Get the names of the dimensions
%
%     NAME = GETDIMNAME(R,N)
%
% Get the name of dimension N from results object R.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function name = getdimname(a,n)

name = a.dimnames;

% If requested, truncate name or add spaces.

if (nargin > 1)
	name = name(n,:);
end

return
