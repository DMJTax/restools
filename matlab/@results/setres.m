%SETRES Replace the data in a results object
%
%      A = SETRES(A,RES)
%
% Replace the data in results object A by RES. This is not often
% necessary, and it is quite annoying, because the sizes of A and RES
% should be identical.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setres(a,res)

if size(res)~=size(a.res)
	error('The res matrix does not have the right size');
end
a.res = res;

return
