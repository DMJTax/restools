%RMBLANKS Remove blanks from a string
%
%              STR = RMBLANKS(STR)
%
% Remove all the blanks in the string STR. Blanks can be spaces
% (char(32)) or zero values (char(0)).
function str = rmblanks(str)

I = find(str==' '|str==0);
if ~isempty(I)
	str(I) = [];
end

return
