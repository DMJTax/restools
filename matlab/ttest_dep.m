function p = ttest_dep(o1,o2)
%TTEST_DEP
%
%    P = TTEST_DEP(O1,O2)
%
% Check if the vectors O1 and O2 have a statistically significant
% different mean. It is assumed that the elements O1_i and O2_i are
% outputs of an identical input, so that the difference between the two
% elements is expected to be zero. Therefore O1 and O2 are not
% independent, but dependent (and therefore the ending '_dep').

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

tol = 1e-5;

% apply it to the differences:
df = o1-o2;
meandf = mean(df);
stddf = std(df);
K = length(df);

% well, if the variance is zero, all other results are significantly
% different....
if stddf<=tol
	% wait, it can happen that m1-m2=0... shall we put then p=0.5?
	if abs(meandf)<=tol
		p = 0.5;
	else
		p = 0;
	end
else
	t = sqrt(K)*meandf/stddf;

	p = mytcdf(-t,K-1);
   p
end

return
