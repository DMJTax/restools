%DISPLAY
%
% DISPLAY(R)
%
% Display a result structure.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function display(R)

nrd = size(R.dimnames,1);
sz = ones(1,nrd);
ressz = size(R.res);
sz(1:length(ressz)) = ressz;

fprintf('%s: results %s ',inputname(1),R.name);
if nrd==0
	fprintf('[empty]\n');
else
	if nrd==1
		fprintf('[%d] ',sz);
		fprintf('[%s]\n',R.dimnames);
	else
		fprintf('[%d',sz(1));
		for i=2:length(sz)
			fprintf('x%d',sz(i));
		end
		fprintf('] [%s',deblank(R.dimnames(1,:)));
		for i=2:length(sz)
			fprintf(',%s',deblank(R.dimnames(i,:)));
		end
		fprintf(']\n');
	end
end
