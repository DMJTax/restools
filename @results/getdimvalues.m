%GETDIMVALUES Get dimension values
%
%     DIM = GETDIMVALUES(R,N)
%
% Get the values along dimension N from results object R.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function dim = getdimvalues(a,n)

dim = a.dim;

if (nargin > 1)
	if n>length(dim)
		warning('results:getdimvalues:dimNotPresent',...
			'Dimension %d is not present in the results.',n);
		dim = [];
	else
		dim = dim{n};
	end
end

return
