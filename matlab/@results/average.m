function R = average(R,dim,boldtype,testtype,use_ste,alpha)
%AVERAGE Average over a results dimension 
%
%    R = AVERAGE(R,DIM,BOLDTYPE,TESTTYPE)
%
% Average the results in object R along dimension DIM. When dimension
% DIM has more than one element, both the mean and standard error of the
% mean is computed. Furthermore, it is checked which values are
% significantly different. This significance test is performed along the
% dimension indicated by BOLDTYPE:
%
%   BOLDTYPE = 'max1' find the elements along dimension 1 that is not
%                     significantly worse than the max value
%   BOLDTYPE = 'min3' find the elements along dimension 3 that is not
%                     significantly higher than the min value
%
% Finally, TESTTYPE indicates if the significance test can assume that
% the elements along the dimension mentioned in BOLDTYPE should be the
% same, or are independently drawn from a distribution:
%   TESTTYPE = 'win'  only give the winning entry (this means no
%                     significance is computed)
%            = 'dep'  assume idetically sampled (this means that a
%                     T-test on the differences is done to see if the
%                     differences are significantly different from
%                     zero: the paired-differences T-test on n-fold
%                     crossvalidation )
%            = 'ind'  assume independent samples (default, this means
%                     that only a T-test on the differences in the
%                     means is performed)
% For this ttest per default a significance level of 5% is used.
%
%    R = AVERAGE(R,DIM,BOLDTYPE,TESTTYPE,USE_STE)
%
% In some cases you may not be interested in the standard deviation of
% the results, but on the standard error of the mean estimation. The
% standard deviation gives an idea how much the results vary, while the
% standard error gives an idea how well the mean is estimated. Per
% default the standard deviation is given.
%
% SEE ALSO
%  RESULTS, SHOW

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<6
   alpha = 0.05;
end
if nargin<5 || isempty(use_ste)
	use_ste = 0;
end
if nargin<4 || isempty(testtype)
	testtype = 'ind';
end
if nargin<3 || isempty(boldtype)
	boldtype = '';
end

if dim>size(R.dimnames,1)
	error('Dim requested larger than size of results.');
end

% Compute the mean.
Rmean = mymean(R.res,dim);
% fill in the other default settings:
N = size(R.dim{dim},1);
if N>1 %then averaging is useful:-)
	if use_ste
		Rstd = myste(R.res,[],dim);
		newdimname = sprintf('Average (ste over %d)',size(R.res,dim));
		R.dim{dim} = ['mean';'ste ';'bold'];
	else
		Rstd = mystd(R.res,[],dim);
		newdimname = sprintf('Average (std over %d)',size(R.res,dim));
		R.dim{dim} = ['mean';'std ';'bold'];
	end
	R.dimnames(dim,1:length(newdimname)) = newdimname;
else
	Rstd = zeros(size(Rmean));
end
if ~isempty(boldtype)
	% find the not-significant others (function defined below):
	Rbold = findsignif(R.res,Rmean,dim,boldtype,testtype,alpha);
else
	Rbold = zeros(size(Rstd));
end

% Replace the res with the average, std and bold:
R.res = Rmean;
R.res = cat(dim,R.res,Rstd);
R.res = cat(dim,R.res,Rbold);

return

function Ibold = findsignif(res,Rmean,dim,boldtype,ttype,alpha)
% Find which results are not significantly worse than the best one.
% The tests are defined on the vectors containing the results of one
% experiment, but over probably different runs.
%
% Currently two tests have been implemented:
% ttype = 'dep'   assume that the results on each individual run should
%                 be identical
% ttype = 'indep' assume that the results on each individual run are
%                 still sampled randomly
% ttype = 'win'   the highest/lowest

nrd = length(size(res));

stype = boldtype(1:3);
sdim = str2num(boldtype(4:end));
if ~isa(sdim,'double')
	error('The string "boldtype" does not seem correct.');
end

% Permute the data, such that the comparison is taken over the second
% dimension, and that the average was taken over the first dimension
J = 1:nrd;
J(sdim) = []; J = [sdim J];
J(find(J==dim)) = []; J = [dim J];
Rmean = permute(Rmean,J);
res = permute(res,J);

% When we are interested in min instead of max, we change the sign:
if strcmp(stype,'min')
	Rmean = -Rmean;
	res = -res;
end

% Be robust against NaN's and Inf's:
Ibad = find(~isfinite(Rmean));
Rmean(Ibad) = -inf;
[mx,I] = max(Rmean,[],2);

% 'Unfold' all dimensions 3 and up:
res = res(:,:,:);
% Run over all runs, and later over all values in dim{2} and compute
% where significant differences occur:
Ibold = zeros(size(Rmean));
for i=1:size(res,3)
	mxr = squeeze(res(:,I(1,1,i),i));
	Ifinite = find(isfinite(mxr)); %maybe not all runs are filled...
	mxr = mxr(Ifinite);            % ignore the non-filled runs.
	for j=1:size(res,2)
		switch ttype
		case 'win'
			tval = (I(1,1,i)==j);
		case 'dep'
			tval =  ttest_dep(mxr,squeeze(res(Ifinite,j,i)));
		case {'ind', 'indep'}
			tval =  ttest_indep(mxr,squeeze(res(Ifinite,j,i)));
		otherwise
			error('This type of Ttest is not defined.')
		end
		if tval > alpha
			Ibold(1,j,i) = 1;
		end
	end
end

% Transform Ibold back:
Ibold = ipermute(Ibold,J);

return

