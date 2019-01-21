%TIMES Results overload
function c = times(a,b)

if isa(a,'results')
	c = a;
	if isa(b,'results')
		if ~all(size(a)==size(b))
			error('Sizes of A and B do not match.');
		end
		c.res = a.res .* b.res;
	elseif isa(b,'double')
		if length(b)==1 %scalar
			b = repmat(b,size(a));
		elseif ~all(size(a)==size(b))
			error('Sizes of A and B do not match.');
		end
		c.res = a.res .* b;
	else
		error('I cannot multiply A with B here.');
	end
else
	c = times(b,a);
end
