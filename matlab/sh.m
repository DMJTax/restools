%    SH(FNAME)
%    SH(FNAME,OUTPUTTYPE)
%
% Show the results table of a variable R stored in the mat-file FNAME.
% It is assumed that this results object R has a dimension name 'run'
% over which we can average.
function sh(fname,outputtype);
if nargin<2
	outputtype = 'text';
end

in = load(fname);
parnames = fieldnames(in);
if length(parnames)==1
	R = getfield(in,parnames{1});
else
	if ~isfield(in,'R')
		error('I cannot find parameter R.');
	end
	R = getfield(in,'R');
end
if ~isa(R,'results')
	error('Parameter R is not a results object.');
end
dimnames = getdimnames(R);
nr = strmatch('run',dimnames);
if isempty(nr)
	error('I cannot find the dimension to average over');
end
highl = sprintf('max%d',nr-1);
S = average(100*R,nr,highl,'dep',1);
show(S,outputtype);
