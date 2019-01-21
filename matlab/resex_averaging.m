%RESEX_AVERAGING example on averaging results
%
% This script should show the different possibilities of averaging of
% results.

% Generate (not completely random) results to show:
m = repmat((1:5)'/10,[1,4,10]);
res = m + 0.4*rand(5,4,10);
% Store it in a results object:
R = results(res,{'ldc' 'qdc' 'knnc' 'parzenc' 'svc'},...
   {'data1','iris','ionosphere','dat4'},10);
% Set the dimension names:
R = setdimname(R,'classifiers','datasets','runs');
% Set the results name:
R = setname(R,'performance');

% Average over the runs, make the best classifier bold:
T = average(100*R,3,'max1','ind');
show(T)
% Average over the runs, make the best classifier bold, but assume that
% all the rus were over the same datasets (the results are dependent):
T = average(100*R,3,'max1','dep');
show(T)
% Average over the runs, make the best dataset bold
T = average(100*R,3,'max2','dep');
show(T)
