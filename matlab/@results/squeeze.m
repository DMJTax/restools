%SQUEEZE Squeeze results object
%
%          S = SQUEEZE(R)
%
% Remove the singleton dimensions in the results R.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function S = squeeze(R)

S = R;
sz = size(R);
% when the dimensionality is 2, we cannot remove dimensions anymore (it
% will remove the complete object:))
if length(sz)<=2
	S = R;
	return;
end

% find the singleton dimensions
I = find(sz==1);
if ~isempty(I)
	% update the name of the results object with the dimensions and
	% dimension values that were kept:
	for i=1:length(I)
		str = [rmblanks(R.dimnames(I(i),:)),'=',rmblanks(R.dim{I(i)})];
		S.name = [S.name,' (',str,')'];
	end
	% update the dimnames, dims and results matrix:
	J = find(sz~=1);
	S.dimnames = S.dimnames(J,:);
	S.dim = S.dim(J);
	S.res = squeeze(S.res);
end
