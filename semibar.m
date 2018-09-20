%SEMIBAR Semi-transparant bar graph
%
%    H = SEMIBAR(X,H,CLR,ALPHA_VAL)
%
% Draw a semi-transparant bar graph. The bars are located on position X,
% have height H, and color CLR. The bars are semi-transparant with alpha
% value of ALPHA_VAL.
%
% To try:
% >> [h1,x] = hist( randn(100,1) );
% >> h2 = hist(randn(30,1), x);
% >> semibar(x,h1,'r');
% >> semibar(x,h2,'b');

function h = semibar(x,h,clr,alpha_val)
if nargin<4
   alpha_val = 0.5;
end
if nargin<3
   clr = 'b';
end

h = bar3(x,h,clr);
set(h,'facealpha',0.5);
view(-89.999,0); % don't use -90, because you will not get a white background...
grid off;
box on;
hold on;

