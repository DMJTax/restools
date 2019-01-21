%RESEX_CUT Results example on object cutting/combining
%
% This script should show how a results-object can be combined and cut.

% Generate (not completely random) results to show:
m = repmat((1:10)'/10,[1,4,5]);
res = m + 0.4*rand(10,4,5);
% Store it in a results object:
R = results(res,cellprintf('cl%d',1:10), ...
   {'data1','iris','ionosphere','dat4'}, 5);
R = setdimname(R,'classifiers','datasets','runs');
% we now have:
show(average(R,3))

% Now we remove the third entry of the second dimension (i.e.
% ionosphere):
R(:,3,:) = [];
% and we only use the first 4 entries from the first dimension:
R = R(1:4,:,:);
show(average(R,3))

