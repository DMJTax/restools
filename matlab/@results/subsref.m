%SUBSREF Results overload
function c = subsref(a,s)

% The case of R.name or so
if strcmp(s(1).type,'.')
	switch s(1).subs
	case 'name'
		c = a.name;
	case 'dimnames'
		c = a.dimnames;
	case 'dim'
		c = a.dim;
	case 'res'
		c = a.res;
	end
end

% The case of R(3,:,:) or so
if strcmp(s(1).type,'()')
	c = a;
	str = 'c.res = c.res(';
	str = '(';
	for i=1:length(s(1).subs)
		if strcmp(s(1).subs{i},':')
			str = [str ':,'];
			continue;
		end
		I = s(1).subs{i};
		c.dim{i} = c.dim{i}(I,:);
		str = [str '[' num2str(I) '],'];
	end
	str(end) = ')';
	eval(['c.res = c.res',str,';']);

end

% This is smart: a recursive call to subsref, for things like
%   R.dim{2}
%   R(1:4,:,:).dim{1}
if length(s)>1
	c = subsref(c,s(2:end));
end
return
