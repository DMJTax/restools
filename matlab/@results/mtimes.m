%MTIMES Results overload
function s = mtimes(r,b)

if isa(r,'results') & ~isa(b,'results')
	s = r;
	s.res = r.res * b;
elseif ~isa(r,'results') & isa(b,'results')
	s = b*r;
else
	s = r;
	s.res = r.res * b.res;
end

return
