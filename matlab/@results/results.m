function R = results(res,varargin)
%RESULTS result structure constructor
%
%   R = RESULTS(D,DIM1,DIM2,...)
%
% A results structure is constructed by supplying a 
%   D     data matrix (NxMx...) containing the results
%   DIM1  the values along dimension 1 (this can be a character or
%         double array of Nx...)
%   DIM2  the values along dimension 2 (this can be a character or
%         double array of Nx...)
% The number of dimensions is not restricted.
% The other things, like the name of the results, or the names of the
% dimensions themselves can be set by SET.
%
% Example:
%   err = rand(5,4,10);
%   dim1values = {'nmc','ldc','qdc','parzen','svc'};
%   dim2values = {'none','PCA 95','PCA 99','Fisherm'};
%   dim3values = (1:10)';
%   R = results(err, dim1values,dim2values,dim3values);
%   R = setdimname(R,'classifier','preproc','run');
%   R = setname(R,'first experiment');
%   show(average(100*R,3))
%
% SEE ALSO: SETNAME, SETDIMNAMES, SHOW, AVERAGE

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
if nargin<1
	res = [];
end

R.name = [];
sz = size(res);
nrd = length(sz);

if nargin>1
	% Now the following input arguments should be the names of the
	% dimension values
	if length(varargin)~=nrd
      error(sprintf('I am expecting %d input arguments.',nrd+1));
	end

	% check for each dimension if the values are good.
	R.dimnames = int2str((1:nrd)');
	for i=1:nrd
		% SPECIAL CASE: when you just supply a number, n, and this number
		% is the same as the number of elements in this dimension, you
		% probably want to have  (1:n)':
		if length(varargin{i})<=1 
			if isa(varargin{i},'double')
				if (varargin{i}~=size(res,i))
					warning('results:results',...
					'Number in dim. %d does not fit (it is %d, and the data has %d).',...
					i,varargin{i},size(res,i));
				end
				varargin{i} = (1:size(res,i))';
			end
		end
		% check the size of the dimension entry names
		if size(varargin{i},1)~=size(res,i)
			varargin{i}=varargin{i}';
			if size(varargin{i},1)~=size(res,i)
				error(sprintf('Length of the dimname(%d) does not fit res.',i));
			end
		end
		% make the dimension entry names a column matrix
		if isa(varargin{i},'cell')
			% take care that the dimvalues can be numeric or string:
			if isnumeric(varargin{i}{1})
				varargin{i} = cell2mat(varargin{i}(:));
			else
				varargin{i} = strvcat(varargin{i});
			end
		end
		R.dim{i} = varargin{i};
	end

else
	% Only the results are given, and we fill everything with vectors 1:N
	R.dimnames = int2str((1:nrd)');
	for i=1:nrd
		R.dim{i} = int2str((1:sz(i))');
	end
end

% Finally store the results:
R.res = res;
R = class(R,'results');
superiorto('double');
	
return

