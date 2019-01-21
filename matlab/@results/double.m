%DOUBLE Convert results to double matrix
%
%      C = DOUBLE(R)
%
% Extract the data matrix C from results object R.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function c = double(a)

c = a.res;

return
