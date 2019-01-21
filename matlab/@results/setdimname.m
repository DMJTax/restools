%SETDIMNAME
%
%    A = SETDIMNAME(A,NAME1,NAME2,...)
%    A = SETDIMNAME(A,DIM,NAME)
%
% Set the names of the dimensions.
%
%SEE ALSO
% SETDIMVALUES

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setdimname(a,varargin)

nrd = length(size(a.res));
if length(varargin)==1
	if size(varargin{1},1)~=nrd
		error('You did not supply the right number of dimension names.');
	end
	a.dimnames = varargin{1};
else
	if isa(varargin{1},'double')
		if (varargin{1}>nrd)
			error('Dimension index too large (%d>%d)',varargin{1},nrd);
		end
		if ~isa(varargin{2},'char')
			error('Please supply a string for the dimension name.');
		end
		names = num2cell(a.dimnames,2);
		names{varargin{1}} = varargin{2};
		a.dimnames = strvcat(names);
		return
	end
	if length(varargin)~=nrd
		error('You did not supply the right number of dimension names.');
	end
	for i=1:length(varargin)
		str = varargin{i};
		if ~isa(str,'char') & ~isempty(str)
			error('The name should be a string');
		end
		if i==1
			a.dimnames = str;
		else
			a.dimnames = strvcat(a.dimnames,str);
		end
	end
end
