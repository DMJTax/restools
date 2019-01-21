%PLUS Results overload
function c = plus(a,b)

if isa(a,'results')
	c = a;
	if isa(b,'results')
		if ~all(size(a)==size(b))
			error('Sizes of A and B do not match.');
		end
		c.res = a.res + b.res;
	elseif isa(b,'double')
		if length(b)==1 %scalar
			b = repmat(b,size(a));
		elseif ~all(size(a)==size(b))
			error('Sizes of A and B do not match.');
		end
		c.res = a.res + b;
	else
		error('I cannot B to A here.');
	end
else
	c = plus(b,a);
end
