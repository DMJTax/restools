% SET Set results object fields
%
%   A = SET(A,VARARGIN)
%
% Set the fields in the results object A, like
%    A=SET(A,'name','try','res',rand(10,4,3));
% The following can be set:
%   NAME       name of the results
%   DIMNAME    name of each dimension (char array, Nx...)
%   VALUES     cell-array (1xN) containing character arrays, that
%              contains the dimension values 
%   RES        the data array
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function a = set(a,varargin)

if isempty(varargin), return, end

for j=1:2:nargin-1
	
	name = varargin{j};

	if j == nargin+1
		error('No data found for field')
	else
		v = varargin{j+1};
	end

	switch name

	case 'name'
		a = setname(a,v);
	case {'dimnames','dimname'}
		a = setdimname(a,v);
	case {'dim','values'}
		a = setdimvalues(a,v);
	case 'res'
		a = setres(a,v);
	otherwise
		error('This field is not known.');
	end
end


