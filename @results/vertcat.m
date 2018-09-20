%VERTCAT Results overload
function R = vertcat(varargin)

if nargin==1
	R = varargin{1};
else
	R = cat(1,varargin{:});
end

return
