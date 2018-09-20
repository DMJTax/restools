%CAT Concatenate results 
%
%    R = cat(dim,R1,R2,...)
%
% Concatenate two or more result structures along dimension DIM.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function R = cat(dim,varargin)

% A bit scary, concatenate a long list of variables:
if nargin>3
	part = varargin(1:end-1);
	R = cat(dim, cat(dim,part{:}), varargin{end});
	return
else
	R1 = varargin{1};
	R2 = varargin{2};
end

% Maybe this is stupid, but if R1 or R2 is empty, just return the other
% guy:
if isempty(R1)
	R = R2;
	return
end
if isempty(R2)
	R = R1;
	return
end

% Now check if the dimnames are equal
if size(R1.dimnames,1)~=size(R2.dimnames,1)
	% now it might be possible that the difference is only in the last
	% dimension, and only in that case I can patch it:
	if size(R1.dimnames,1)==size(R2.dimnames,1)+1
		R2.dimnames = strvcat(R2.dimnames,'New dim');
		R2.dim{size(R1.dimnames,1)} = R2.name;
	elseif size(R2.dimnames,1)==size(R1.dimnames,1)+1
		R1.dimnames = strvcat(R1.dimnames,'New dim');
		R1.dim{size(R2.dimnames,1)} = R1.name;
	else  % otherwise it just fails:
		error('Nr of dimensions in R1 and R2 do not match.');
	end
end

% Now check if all dim's are equal for the dimensions
% that are not glued
for i=1:size(R1.dimnames,1)
	if i==dim
		continue;
	end
	if size(R1.dim{i},1)~=size(R2.dim{i},1)
		error('Nr of dim. values in R1.dim(%d) and R2.dim(%d) do not match.', i,i);
	end
	if ~strcmp(R1.dimnames(i,:),R2.dimnames(i,:))
		warning('results:cat:nameMismatch',...
		   'R1 and R2 do not match dimnames (%s!=%s)',...
			R1.dimnames(i,:),R2.dimnames(i,:));
	end
	if ~strcmp(class(R1.dim{i}),class(R2.dim{i}))
		warning('results:cat:typeMismatch',...
			'Types of feature values of dim %d do not match (%s!=%s)',...
			i,class(R1.dim{i}),class(R2.dim{i}));
		R1.dim{i} = char(R1.dim{i});
		R2.dim{i} = char(R2.dim{i});
	end
	if isnumeric(R1.dim{i})
		for j=1:size(R1.dim{i},1)
			if (R1.dim{i}(j,:) ~= R2.dim{i}(j,:))
				warning('results:cat:valueMismatch',...
					'Dimension(%d) value(%d) names not equal: %f!=%f',...
					i,j,R1.dim{i}(j,:),R2.dim{i}(j,:));
			end
		end
	else
		for j=1:size(R1.dim{i},1)
			if ~strcmp(deblank(R1.dim{i}(j,:)),deblank(R2.dim{i}(j,:)))
				warning('results:cat:nameMismatch',...
					'Dimension(%d) value(%d) names not equal: %s!=%s',...
					i,j,deblank(R1.dim{i}(j,:)),deblank(R2.dim{i}(j,:)));
			end
		end
	end
end

% So, it seems OK, so let's glue:
R = R1;
if dim>length(R1.dim)
% Well, do we want to introduce an *extra* dimension? Then we have to
% also invent new dimnames. Use the name of the results file for this.
	if dim>length(R1.dim)+1
		dim = length(R1.dim)+1;
		warning('The dimension number is too large, using dimension %d instead.',dim);
	end
	R.dimnames = strvcat(R.dimnames, 'New dim');
	if isempty(R1.name)
		name1 = ' ';
	else
		name1 = R1.name;
	end
	if isempty(R2.name)
		name2 = ' ';
	else
		name2 = R2.name;
	end
	R.dim{dim} = strvcat(name1,name2);
	R.res = cat(dim,R1.res,R2.res);
else
	% we concatenate along an already existing dimension:
	if isnumeric(R1.dim{dim})
		R.dim{dim} = [R1.dim{dim}; R2.dim{dim}];
	else
		R.dim{dim} = strvcat(R1.dim{dim},R2.dim{dim});
	end
	R.res = cat(dim,R1.res,R2.res);
end

return
