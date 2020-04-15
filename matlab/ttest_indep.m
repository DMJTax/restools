function p = ttest_indep(o1,o2)
%TTEST_INDEP
%
%    P = TTEST_INDEP(O1,O2)
%
% Check if the vectors O1 and O2 have a statistically significant
% different mean. It is assumed that the elements O1_i and O2_i are
% outputs of different inputs, so only the means and the standard
% deviations of O1 and O2 are considered (and therefore the ending
% '_indep').

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


n1 = length(o1);
n2 = length(o2);
m1 = mymean(o1);
m2 = mymean(o2);
s1 = mystd(o1);
s2 = mystd(o2);

tol = 1e-5;
dof = n1+n2-2;

s12 = sqrt(((n1-1)*s1*s1 + (n2-1)*s2*s2) / dof );

% well, if the variance is zero, all other results are significantly
% different....
if s12<=tol
	% wait, it can happen that m1-m2=0... shall we put then p=0.5?
	if abs(m1-m2)<=tol
		p = 0.5;
	else
		p = 0;
	end
else
	t = abs(m1-m2)/(s12 * sqrt(1/n1 + 1/n2));

	p = 2*mytcdf(-t,dof);
end

return
