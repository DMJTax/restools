%UPDATERESULTS Update one entry 
%
%       R = UPDATERESULTS(R,DIM,ID,RES)
%
% Update an entry in results R. The entry is identified by ID along
% dimension DIM. When the entry is found, the results will be replaced
% by RES. When the entry is not found, a new entry is added to dimension
% DIM.
function R = updateresults(R,dim,id,res)

% get the id's along dimension DIM:
vals = getdimvalues(R,dim);
if isempty(vals)
	return;
end
if class(vals)~=class(id)
	warning('The class of ID does not match the values of dim.%d in R.\n',dim);
	return;
end
% check sizes
sz = size(R);
if length(size(res)) == length(sz)-1
	% ok, ignore that one dimension:
	sz(dim) = [];
else
	sz(dim) = 1;
end
if any(sz~=size(res))
	warning('Sizes of RES and entry in R do not match.');
	return;
end
% find the entry:
if isa(id,'char') %string matching:
	I = strmatch(id,vals,'exact');
else
	if ~isa(id,'double')
		warning('I expect ID to be a character string.');
		id = 1;
	end
	I = id;
end
if length(I)>1
	error('More than one match found! Use the first one.');
	I = I(1);
end
if isempty(I) % not found, add it:
	disp('Add entry');
	I = size(vals,1)+1;
	vals = strvcat(vals,id);
end
% do a complicated 'eval'
str = 'R(';
for i=1:length(size(R))
	if (i==dim)
		str = [str,'I'];
	else
		str = [str,':'];
	end
	str = [str,','];
end
str(end) = ')';
str = [str,' = res;'];
% replace the values
eval(str);
% make sure the name of the entry is OK:
R = setdimvalues(R,dim,vals);

