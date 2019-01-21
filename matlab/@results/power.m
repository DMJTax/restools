%POWER Results overload

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = power(a,b)

if isa(b,'double')
	a.res = (a.res).^b;
else
	error('The power has to be a scalar.');
end

end
