%HORZCAT Results overload
function R = horzcat(varargin)

if nargin==1 %Matlab bug, sometimes horzcat is called after vertcat..?
	R = varargin{1};
else
	R = cat(2,varargin{:});
end

return
