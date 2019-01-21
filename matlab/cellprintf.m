function s = cellprintf(str,varargin)
%CELLPRINTF Write formatted data to cell array
%
%    S = CELLPRINTF(FORMAT,VARARGIN)
%
% Create text strings in a cell array, using format FORMAT. The string
% FORMAT is the same as is used in fprintf or sprintf. The next input
% arguments are vector inputs that are then filled in FORMAT.
% An example:
%  >> cellprintf('Hallo %d, %d',1:5, [3 5 4 8 5])
%  ans =
%   'Hallo 1, 3'
%   'Hallo 2, 5'
%   'Hallo 3, 4'
%   'Hallo 4, 8'
%   'Hallo 5, 5'

N = length(varargin);
nr = length(varargin{1});
for i=2:N
	if length(varargin{i})~=nr
		error('All input arguments have to have equal length');
	end
end
s = cell(nr,1);
for i=1:nr
	in = {};
	for j=1:N
		in{j} = varargin{j}(i);
	end
	s{i} = sprintf(str,in{:});
end
return

