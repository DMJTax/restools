%ERRORBAND Create errorbar with semi-transparant errors
%
%     H = ERRORBAND(X,F,E)
%
% Plot a function like errorbar, plotting values F as a function of X,
% with an error E, except that the errorbars are replaced by a
% semi-transparant band (such that several plots can be made on top of
% each other).
%
%     H = ERRORBAND(X,F,E,CLR,ALPHA)
%
% Plot the function F in color CLR, and the alpha-transparancy is set to
% ALPHA.
%
% Note: the transparancy is handled by OpenGL, and when you use the
% Matlab 'print' command, you will obtain a raster image (which is
% ugly). To avoid this, you can use the command 'plot2svg' from
% Mathworks file-exchange. The resulting .svg-file has the transparancy.
% To include this in latex, you have to convert this .svg to a .pdf (you
% can do that with Inkscape).

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function h = errorband(x,f,e,clr,alpha_val)

if nargin<5
   alpha_val = 0.5;
end
if nargin<4
   clr = 'r';
end

% make all vectors column vectors:
x = x(:);
f = f(:);
e = e(:);
% define the error region:
rx = [x; flipud(x)];
ry = [f-e; flipud(f+e)];

% make the plot:
h0 = errorbar(x,f,e,'w'); % make sure that the axis are the same as in errorbar
V=axis;
delete(h0);

h1 = patch(rx,ry,clr);
set(h1,'linestyle','none','facealpha',alpha_val);
hold on;
h2 = plot(x,f,clr);
set(h2,'linewidth',2);
axis(V);

% return handles on request:
if nargout>0
   h = [h1;h2];
end

