%    R = SORTDIM(R,DIM,MODE)
%
% Sort the results R along the values of dimension DIM in ascending
% order (when MODE='ascend') or in descending order (when
% MODE='descend').
%
% Example:
% >> x = rand(5,3);
% >> R = results(x,5,{'pear' 'lemon' 'apple'});
% >> T = sortdim(R,2);
% >> show(T)
% 1 |apple |lemon |pear 
% --+-----+-----+-----
% 1 | 1.0 | 0.5 | 0.6 
% 2 | 0.2 | 0.1 | 0.9 
% 3 | 0.6 | 0.8 | 0.8 
% 4 | 0.6 | 0.7 | 0.1 
% 5 | 0.3 | 0.1 | 0.3 

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function R = sortdim(R,dim,mode)

if nargin<3
	mode = 'ascend';
end
if nargin<2
	dim = 1;
end

dimvalues = getdimvalues(R,dim);
switch mode
case 'ascend'
	[newdimvalues,I] = sortrows(dimvalues);
case 'descend'
	[newdimvalues,I] = sortrows(dimvalues,-1);
otherwise
	error('Mode can be ascend or descend.');
end
% reshuffle dimension dim:
nrdims = length(size(R));
str = 'R.res = R.res(';
for i=1:nrdims
	if i==dim
		str = [str,'I,'];
	else
		str = [str,':,'];
	end
end
str(end:end+1) = ');';
eval(str);
R = setdimvalues(R,dim,newdimvalues);
