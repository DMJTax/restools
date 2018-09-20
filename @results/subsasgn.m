%SUBSASGN Results overload

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = subsasgn(a,s,b)

% the structure fields assignments:
if strcmp(s(1).type,'.')
	if length(s)>1 & strcmp(s(1).subs,'dim')
		a = setdimvalues(a,b,s(2).subs{1});
	else
		a = set(a,s(1).subs,b);
	end
	return
end

% the matrix index assignment:
if strcmp(s(1).type,'()')
	% check if the number of indices is not too large for what we have:
	if length(s(1).subs)>ndims(a.res)
		error('Index is too large for the number of dimensions (use CAT instead).');
	end
	% construct a string, so we can perform an eval() later:
	noncolon = 0; colondim = 0;
	I = '(';
	for i=1:length(s(1).subs)
		if strcmp(s(1).subs{i},':')
			% use all elements for dimension i:
			I = [I ':,'];
			colondim = i;
		else
			% use a subset of elements for dimension i:
			if s(1).subs{i}>size(a,i)
				 %feature i will be extended, invent an extra feature
				 %element name:
				 %(note that more than one element may have to be added to
				 %fit all the new data that is supplied in the subsasgn:)
				 n = max(s(1).subs{i}-size(a,i));
				 a.dim{i} = strvcat(a.dim{i},repmat('new',n,1));
			end
			I = [I '[' num2str(s(1).subs{i}) '],'];
			noncolondim = i;
			noncolon = noncolon+1;
		end
	end
	I(end) = ')';
	if isempty(b)
		% In the assignment we have the possibility to remove elements.
		% Things become hairy/impossible if there is more than one non-colon.
		if noncolon~=1
			error('A null assignment can have only one non-colon index.');
		end
		% remove the elements:
		eval(['a.res' I ' =[];']);
		% and fix also the elements in the dimnames:
		a.dim{noncolondim}(s(1).subs{noncolondim},:) = [];
	else  % or to change the elements:
		% (the + is needed in the case b is a results object itself)
		eval(['a.res' I ' = +b;']);
	end
end

