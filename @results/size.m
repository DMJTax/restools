%SIZE Results overload
function varargout = size(R,dim)

nrd = size(R.dimnames,1);
sz = ones(1,nrd);
ressz = size(R.res);
sz(1:length(ressz)) = ressz;

%DXD: maybe here I can check the internal sizes??

if nargin==2
	sz = sz(dim);
end
if nargout == 0
	sz+0  % to get "ans = "
elseif nargout==1
	varargout{1} = sz;
else
	for i=1:nargout
		if i<=nrd
			varargout{i} = sz(i);
		else
			varargout{i} = 1;
		end
	end
end
	
