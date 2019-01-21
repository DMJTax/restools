%GETNAME Get the name of a results object
%
%     NAME = GETNAME(R,N)
%
% Get the name of a results object R. If requested, the name can be
% extended or truncated to have length N.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function name = getname(a,n)

	name = a.name;

	% If requested, truncate name or add spaces.

	if (nargin > 1)
		if (length(name) > n)
			name = name(1:n);
		else
			name = [name,repmat(' ',1,n-length(name))];
		end
	end

return
