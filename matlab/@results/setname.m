%SETNAME Set the name (title) of a results var.
%
%    A = SETNAME(A,STR)
%
% Set the name (or title) of a results object A to STR.
%
%    A = SETNAME(A,STR,N1,N2,...)
%
% Set the name to formatted string STR, where STR can be formatted as in
% sprintf, using the extra input arguments N1, N2, ...

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setname(a,str,varargin)

if ~isa(str,'char') & ~isempty(str)
	error('The name should be a string');
end
if nargin>2
	a.name = sprintf(str,varargin{:});
else
	a.name = str;
end

return
