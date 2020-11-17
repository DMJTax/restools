%SHOW Show a results object
%
%    SHOW(R,OUTPUTTYPE,NUMFORMAT,NOSTD)
% 
% Plot a result structure R in a table in different formats on the
% screen.  The possibilities for OUTTYPE are
%     'text'     plain text in the Matlab window
%     'latex'    table that can be copied into a .tex file
%     'html'     table that can be put into a html file
%     'graph'    Matlab plot, with continuous lines
%     'bar'      bar plot in Matlab
%     'surf'     surface plot
%
% For the first three output possibilities, it is also possible to set
% the plotting format in 'fprintf' strings, like NUMFORMAT='%5.2f'
%   show(100*R,'latex','%5.2f');
% Finally, when NOSTD is set to nonzero, no standard deviations are
% shown in the table.
%
%    SHOW(FID,...)
% 
% When a file identifier is supplied, the table is printed into the
% file.
%
% SEE ALSO
%   RESULTS, AVERAGE

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function h=show(fid,R,outputtype,numformat,nostd)

% check if we have a file identifier:
if isa(fid,'results')  % no file id. is supplied
	if nargin>3
		nostd = numformat;
	else
		nostd = 0;
	end
	if nargin>2,
		numformat = outputtype;
	else
		numformat = '%2.1f';
	end
	if nargin>1,
		outputtype = R;
	else
		outputtype = 'text';
	end
	R = fid;
	fid = 1; % make it stdout
else  % we have an fid, but do we have 'numformat' defined?
	if nargin<5
		nostd = 0;
	end
	if nargin<4
		numformat = '%2.1f';
	end
	if nargin<3
		outputtype = 'text';
	end
end

% Check that we have maximally 3 dimensions
nrd = size(R.dimnames,1);
if nrd>3
	% maybe there are singleton dimensions?
	R = squeeze(R);
	if size(R.dimnames,1)>3
		warning('resuls:show:morethan3D','Results structure contains more than 3 dimensions.');
		%DXD error or warning here?!
		nrd = size(R.dimnames,1);
	end
end

% Dimensions that only have one value should be ignored. They will be
% permuted till a dimension with more than 1 value is found.
% The only exception is when we have already a 2D table, then the first
% dim may have one element
%if length(size(R)) ~= 2
%%	I0 = (size(R)==1); % find dims with one value
%	cI0 = cumsum(I0); 
%	if (cI0(1)<nrd) & (cI0(1)>0) % we found a good permutation
%		Iperm = circshift((1:nrd)',-cI0(1));
%		R = permute(R,Iperm);
%	end
%end

% The default settings:
Rmean = R.res(:,:,1);
Rstd = [];
Rbold = zeros(size(Rmean));
Rmeantitle = '';

%Find which dimension has the average:
avdim = strmatch('Average (',R.dimnames);
if ~isempty(avdim) % there *is* an averaging dimension
	order = 1:nrd;
	order(avdim) = [];
	if nrd>3
		order = [order(1:2) avdim order(3:end)];
	else
		if nrd==3
			order = [order(1:2) avdim];
		else % we only started with 2D matrix, aaargh!
			% Exceptions exceptions: be careful, we may want to have a
			% transposed version:
			if (avdim==1)
				order = [3 order avdim];
			else
				order = [order 3 avdim];
			end
			% we have to invent an empty dimension...:
			R.dimnames = char(R.dimnames,'.');
			%R.dim{3} = 'mean (std)';
			% I added an extra empty dimension, and now I have to invent a
			% good name for it: use the dimension name:
			R.dim{3} = R.dimnames(2,:);
		end
	end
	R.dimnames = R.dimnames(order,:);
	R.dim = R.dim(order);
	R.res = permute(R.res,order);
	% Check if the avdim dimension contains 'mean' 'std ' ['bold']
	% and fill Rmean, Rstd, Rbold
	if (size(R.dimnames,1)>2)
		i = strmatch('mean',R.dim{3});
		if ~isempty(i)
			Rmean = R.res(:,:,i);
			Rmeantitle = R.dimnames(3,:);
		end
		i = strmatch('std ',R.dim{3});
		if isempty(i) % we can have std or ste in the value name
			i = strmatch('ste ',R.dim{3});
		end
		if ~isempty(i)
			Rstd = R.res(:,:,i);
		end
		i = strmatch('bold',R.dim{3});
		if ~isempty(i)
			Rbold = R.res(:,:,i);
		end
	end
end

if ~isempty(Rstd) && (nostd==0)
	singleout = 0;
	% Fix a bug in fprintf, that for very very small values, you might
	% get printed  -0.000  when it should be 0:
	Rstd = Rstd+eps;
else
	singleout = 1;
end

% Take care for the names, tick labels and sizes:
Xname = deblank(R.dimnames(2,:));
Yname = deblank(R.dimnames(1,:));
if isstring(R.dim{2})
   Xlabels = R.dim{2};
else
   Xlabels = num2str(R.dim{2});
end
if isstring(R.dim{1})
   Ylabels = R.dim{1};
else
   Ylabels = num2str(R.dim{1});
end
[nrx,widthx] = size(Xlabels);
[nry,widthy] = size(Ylabels);
namewidth = max(widthy,length(Yname));
if namewidth>30, namewidth=30; end
titleformatstr = sprintf('%%%ds ',namewidth);
% find out if we are working with discrete numbers on the x-axis, or
% that we are working with real-valued x's:
if isnumeric(R.dim{2})
	numericXvalues = 1;
	xvalues = R.dim{2};
else
	numericXvalues = 0;
	xvalues = 1:nrx;
end

% Now do the plotting:
switch outputtype
case 'text'
	% check if we can write bold in this terminal
	if usejava('desktop')
		canwritebold = 0;
	else
		canwritebold = 1;
	end
	% TEXT output:
	if singleout
		numformat = [numformat,' '];
		numlen = length(sprintf(numformat,0));
	else
		numformat = [numformat,' (',numformat,') '];
		numlen = length(sprintf(numformat,0,0));
	end
	ttlformat = ['|%',num2str(numlen),'s '];
	% plot the titles:
	fprintf(fid,' **** %s *****\n',R.name);
	if ~isempty(Rmeantitle)
		fprintf(fid,' **** %s *****\n',Rmeantitle);
	end
	fprintf(fid,titleformatstr,' ');
	fprintf(fid,'| %s \n',Xname);
	fprintf(fid,titleformatstr,Yname);
	for j=1:nrx
		fprintf(fid,ttlformat,deblank(Xlabels(j,:)));
	end
	fprintf(fid,'\n%s',repmat('-',1,namewidth+1));
	str = ['+' repmat('-',1,numlen+1)];
	fprintf(fid,'%s\n',repmat(str,1,nrx));
	for i=1:nry
		% the dimension:
		fprintf(fid,titleformatstr,Ylabels(i,:));
		% start the data:
		for j=1:nrx
			fprintf(fid,'| ');
			if isfinite(Rbold(i,j)) && Rbold(i,j) && canwritebold
				%fprintf(fid,[char(27) '[1;34m']);
				fprintf(fid,[char(27) '[1m']);
			end
			if singleout
				fprintf(fid,numformat,Rmean(i,j));
			else
				fprintf(fid,numformat,Rmean(i,j),Rstd(i,j));
			end
			if isfinite(Rbold(i,j)) && Rbold(i,j) && canwritebold
				fprintf(fid,[char(27) '[0;0m']);
			end
		end
		fprintf(fid,'\n');
	end
case 'latex'
	% LATEX output:
	if singleout
		numformat = [numformat,' '];
		numlen = length(sprintf(numformat,0));
	else
		numformat = [numformat,' (',numformat,')'];
		numlen = length(sprintf(numformat,0,0));
	end
	ttlformat = ['& %',num2str(numlen),'s '];
	% remove the underscores from the Xlabels and Ylabels:
	I = find(Xlabels=='_');
	if ~isempty(I)
		Xlabels(I) = ' ';
	end
	I = find(Ylabels=='_');
	if ~isempty(I)
		Ylabels(I) = ' ';
	end
	% plot the titles:
	%fprintf(fid,'\\begin{table}[ht]\n');
	%if ~isempty(R.name)
	%	fprintf(fid,'\\caption{%s}\n',R.name);
	%end
	%fprintf(fid,'\\begin{center}\n');
	fprintf(fid,'\\begin{tabular}{l*{%d}{c}}\n',nrx);
	fprintf(fid,'& \\multicolumn{%d}{c}{%s} \\\\\n',nrx,Xname);
	fprintf(fid,titleformatstr,Yname);
	for j=1:nrx
		fprintf(fid,ttlformat,deblank(Xlabels(j,:)));
	end
	fprintf(fid,'\\\\ \n \\hline \n');
	for i=1:nry
		% the dimension:
		fprintf(fid,titleformatstr,Ylabels(i,:));
		% start the data:
		for j=1:nrx
			fprintf(fid,'& ');
			if isfinite(Rbold(i,j)) && Rbold(i,j)
				fprintf(fid,'{\\bf ');
			end
			if singleout
				fprintf(fid,numformat,Rmean(i,j));
			else
				fprintf(fid,numformat,Rmean(i,j),Rstd(i,j));
			end
			if isfinite(Rbold(i,j)) && Rbold(i,j)
				fprintf(fid,'}');
			end
		end
		fprintf(fid,'\\\\\n');
	end
	fprintf(fid,'\\end{tabular}\n');
   %fprintf(fid,'\\end{center}\n\\end{table}\n');
case 'html'
	% HTML output:
	oldform = numformat;
	if singleout
		numformat = ['<td> ',oldform,' </td>'];
		boldnumformat = ['<td><b> ',oldform,' </b></td>'];
	else
		numformat = ['<td> ',oldform,' (',oldform,') </td>'];
		boldnumformat = ['<td><b> ',oldform,' (',oldform,') </b></td>'];
	end
	numlen = length(numformat);
	ttlformat = ['<th> %',num2str(numlen-5),'s </th>'];
	% plot the titles:
	fprintf(fid,'<table border=1>\n<caption>%s</caption><tr>\n',R.name);
	fprintf(fid,'<th> %s </th>\n',Yname);
	fprintf(fid,'<th colspan=%d>%10s</th>',nrx,Xname);
	fprintf(fid,'</tr>\n<tr>\n');
	fprintf(fid,'<td></td>\n');
	for j=1:nrx
		fprintf(fid,ttlformat,Xlabels(j,:));
	end
	fprintf(fid,'</tr>\n');
	for i=1:nry
		fprintf(fid,'<tr>');
		% the dimension:
		% DXD: do this in bold or not??
		%fprintf(fid,'<th> %10s </th>',Ylabels(i,:));
		fprintf(fid,'<td> %10s </td>',Ylabels(i,:));
		% start the data:
		for j=1:nrx
			if singleout
            if isfinite(Rbold(i,j)) && Rbold(i,j)
					fprintf(fid,boldnumformat,Rmean(i,j));
				else
					fprintf(fid,numformat,Rmean(i,j));
				end
			else
            if isfinite(Rbold(i,j)) && Rbold(i,j)
					fprintf(fid,boldnumformat,Rmean(i,j),Rstd(i,j));
				else
					fprintf(fid,numformat,Rmean(i,j),Rstd(i,j));
				end
			end
		end
		fprintf(fid,'</tr>\n');
	end
   fprintf(fid,'</table>\n');
case 'graph'
	% Matlab line plot (graph) output:
	if ~ishold, clf; end;
	hold on;
	% overrule the default colororder??
	set(gca,'colororder',[0 0 0; 0 0 1; 0 0.8 0; 1 0 0; ...
	                      0.7 0.4 0; ...
	                      0.8 0.8 0; 0 0.8 0.8; 0.8 0 0.8]);

	% check if we only have a line definition or also a color definition:
	if hascolordef(numformat)
		linedef = '';
	else
		linedef = numformat;
		if (linedef(1)=='%') 
			% when the formatting is actually defined for a (latex) table,
			% we have to fall back to a standard line:
			linedef = '-';
		end
		if (size(linedef,1)==1)
			linedef = repmat(linedef,nry,1);
		end
		numformat = '';
	end
	% first define the colors of the linetypes:
	if isempty(numformat) | (numformat(1)=='%') 
		clrs = get(gca,'colororder');
	else
		clrs = numformat;
    end
	% make sure I have enough colors:
	nrclrs = size(clrs,1);
	clrs = repmat(clrs,ceil(nry/nrclrs),1);
    
	% now draw line per line
	for i=1:nry
      if ~singleout && (i>1) % shift the errorbars a tiny bit to avoid overlap
         V = axis;
         dx = i*(V(2)-V(1))/10000;
      else
         dx = 0;
      end
		% remove blank spaces in the definition of the line definition
		if isa(clrs(i,:),'char')  % we have a line definition
			if singleout
            H = plot(xvalues,Rmean(i,:),deblank(clrs(i,:)));
         else
				H = errorband(xvalues+dx,Rmean(i,:),Rstd(i,:),deblank(clrs(i,:)));
            hold on;
            H = plot(xvalues+dx,Rmean(i,:),deblank(clrs(i,:)));
			end
		else                      % we only have a color definition
			if singleout
            H = plot(xvalues,Rmean(i,:),deblank(linedef(i,:)),'color',clrs(i,:));
         else
				H = errorbar(xvalues+dx,Rmean(i,:),Rstd(i,:),deblank(linedef(i,:)),...
				'color',clrs(i,:));
            hold on;
            H = plot(xvalues+dx,Rmean(i,:),deblank(linedef(i,:)),'color',clrs(i,:));
         end
		end
      set(H,'linewidth',1.5); %DXD good idea?
		h(i) = H(1);
	end
   if ~singleout && (i>1) % extend the axis a bit as well...
      V = axis;
      V(2) = V(2) + (nry+1)*dx;
      axis(V);
   end
	if ~numericXvalues
		set(gca,'xtick',1:nrx);
		set(gca,'xticklabel',Xlabels);
	end
	xlabel(Xname);
	%ylabel(R.name);
	legend(h,Ylabels,'location','best');
	title(R.name);
case 'bar'
	% Matlab bar plot output:
	clf; hold on;
	% first define the colors of the linetypes:
	if isempty(numformat) | (numformat(1)=='%')
		clrs = get(gca,'colororder');
	else
		clrs = numformat;
	end
	% make sure i have enough colors:
	nrclrs = size(clrs,1);
	clrs = repmat(clrs,ceil(nry/nrclrs),1);

	% now draw the bars:
	h = bar(Rmean');
   if length(h)==1 % Matlab R2018a
      x=get(h,'xdata');
      hold on;
      errorbar(x,Rmean,Rstd,'k','linestyle','none')
   else
         
      % fix the colors and put some errorbar:
      for i=1:length(h)
         %set(h(i),'facecolor',clrs(i,:));
         if ~isempty(Rstd)
            ch = get(h(i),'children');
            if isempty(ch) %Matlab R2016b 
               [nrbars,nrgroups] = size(Rmean);
               groupwidth = min(0.8, nrbars/(nrbars + 1.5));
               for i = 1:nrbars
                % Calculate center of each bar
                  x = (1:nrgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nrbars);
                  errorbar(x, Rmean(i,:), Rstd(i,:), 'k', 'linestyle', 'none');
               end
            else
               ex = get(ch,'xdata');
               ex = mean(ex(2:3,:),1);
               ey = get(ch,'ydata');
               errorbar(ex,ey(2,:),Rstd(i,:),'k.');
            end
         end
      end
	end
	set(gca,'xtick',1:nrx);
	set(gca,'xticklabel',cellstr(Xlabels));
   set(gca,'XTickLabelRotation',45);
	xlabel(Xname);
	%ylabel(R.name);
	hl = legend(h,Ylabels);
	title(R.name);
case 'surf'
	% Matlab surface plot output:
	dim1 = R.dim{1};
	if ~isa(dim1,'double')
		dim1 = str2num(dim1);
	end
	dim2 = R.dim{2};
	if ~isa(dim2,'double')
		dim2 = str2num(dim2);
	end
	% take care for the tick-labels:
	if ~isempty(dim1) & ~isempty(dim2)
		surf(dim2,dim1,Rmean);
	else
		surf(Rmean);
		set(gca,'xtick',1:nrx);
		set(gca,'xticklabel',Xlabels);
		set(gca,'ytick',1:nry);
		set(gca,'yticklabel',Ylabels);
	end
	% and finally all labels
	xlabel(Xname);
	ylabel(Yname);
	title(R.name);
otherwise
	error('This outputtype is not defined.');
end
if isempty(avdim)
	if size(R.dimnames,1)>2
		% make a notification that we use the first value for dimension 3
		fprintf('\n(Notice that only %s(%s) is used!)\n',...
		deblank(R.dimnames(3,:)), deblank(num2str(R.dim{3}(1,:))));
	end
end

if nargout<1
	clear h;
end
return


function out = hascolordef(in)

out = 0;
if isempty(in)
	return;
end
if isa(in,'double') & size(in,2)==3
	out = 1;
	return
end

if isa(in,'char')
	if (in(1)=='r') | (in(1)=='g') | (in(1)=='b') | ...
		(in(1)=='c') | (in(1)=='m') | (in(1)=='y') | ...
		(in(1)=='w') | (in(1)=='k')
		out = 1;
		return
	end
end

return
