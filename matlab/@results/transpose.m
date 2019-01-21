%TRANSPOSE
%
% R = TRANSPOSE(R)
%
% Transpose the result object R. If the number of dimensions is larger
% than 2, only the first 2 are swapped.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function R = transpose(R)

nrd = size(R.dimnames,1);
order = 1:nrd;
order(1:2) = [2 1];
R = permute(R,order);

