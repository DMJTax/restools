%CATFILES Concatenate results from mat-files
%
%       R = CATFILES(DIM,FILENAME1,FILENAME2, ... )
%
% Concatenate the results that are stored in different mat-files
% FILENAME1, FILENAME2, .... It is assumed that the files contain a
% single results structure, or at least one in variable 'R'.
% The results are concatenated along dimension DIM. When one of the
% other dimensions does not fit (imagine that for some datasets you have
% 10-fold crossvalidation, while others only have 5-fold), the remaining
% values are filled with NaNs. Note that this implementation accepts
% just a single non-fitting dimension, otherwise it is too suspect.
%
% See also: CAT

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function R = catfiles(dimnr,varargin)

if ~isnumeric(dimnr)
    error('First argument should be the dimension.');
end
R = [];
N = length(varargin);
for i = 1:N
	% check if the file exist at all:
	if ~exist(varargin{i},'file')
		if ~exist([varargin{i},'.mat'],'file')
			error('I cannot find file %s',varargin{i});
		end
	end
	% load it 
	in = load(varargin{i});
	% check if there was just a single variable stored in the file
	fn = fieldnames(in);
	if length(fn)==1
		% extract the single variable
		fn_nr = 1;
	else
		% check if one of the variables was called 'R':
		fn_nr = strmatch('R',fn);
		if isempty(fn_nr)
			% now I am confused:
			error('Several variables available, but no R.');
		end
	end
	Ri = getfield(in,fn{fn_nr});
	% This should be a results object:
	if ~isa(Ri,'results')
		error('The variable (R) in %s is not a results object.', ...
			varargin{i});
	end
	% this results object should be concatenated with the existing
	% results:
	% only do it if we didn't start with an empty R:
	if isempty(R)
		R = Ri;
		warning('off','results:getdimvalues:dimNotPresent');
			dimvalues = getdimvalues(Ri,dimnr);
		warning('on','results:getdimvalues:dimNotPresent');
		if isempty(dimvalues)
			dimvalues = varargin{i};
		end
	else
		% for that, we have to check the size:
		sz = size(R);
		szi = size(Ri);
		% ignore the size of the dimension that we use for concatenation:
		sz(dimnr) = 0; szi(dimnr) = 0;
		% where are the differences in size now:
		dff = sz-szi;
		Idff = find(dff);
		% I can accept a difference in one dimension. If there are more
		% differences, I bail out, because then it because suspicious...
		if ~isempty(Idff)
			if length(Idff)>1
				error('New results from %s differ in size in more than 1 dimension.', ...
					varargin{i});
			end
			% fix this single dimension by adding NaNs
			dff = dff(Idff);  % thats how much we have to add:
			if dff>0  % the new results have to be extended
				sz = size(Ri);
				sz(Idff) = dff;
				warning('off','results:cat:nameMismatch');
					Ri = cat(Idff,Ri,results(repmat(NaN,sz)));
				warning('on','results:cat:nameMismatch');
				% borrow the dim-names from R:
				Ri = setdimvalues(Ri,Idff,getdimvalues(R,Idff));
			else  % the new results are larger, so we have to extend the
				% original... woow
				sz = size(R);
				sz(Idff) = -dff;
				warning('off','results:cat:nameMismatch');
					R = cat(Idff,R,results(repmat(NaN,sz)));
				warning('on','results:cat:nameMismatch');
				% borrow the dim-names from Ri:
				R = setdimvalues(R,Idff,getdimvalues(Ri,Idff));
			end
		end
		% now all sizes were correct, so just do the standard cat:
		R = cat(dimnr,R,Ri);
		% and collect the names:
		warning('off','results:getdimvalues:dimNotPresent');
			newdimvalues = getdimvalues(Ri,dimnr);
		warning('on','results:getdimvalues:dimNotPresent');
		if isempty(newdimvalues)
			newdimvalues = varargin{i};
		end
		dimvalues = strvcat(dimvalues,newdimvalues);
	end
end
% finally, fix the dimension names, use the filenames:
% (check for the stupid case that we only concatenate a single file,
% then this dimension may not really exist yet!)
if dimnr<=length(size(R))
	R = setdimvalues(R,dimnr,dimvalues);
	R = setdimname(R,dimnr,'filenames');
end

return
