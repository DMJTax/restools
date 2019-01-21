%RESEX_SIMPLE basic example script
%
% This script should show how a results-object can be created, and how
% to make nice tables and figures form it.

% Generate (not completely random) results to show:
m = repmat((1:5)'/5,[1,4,5]);
res = m + 0.4*rand(5,4,5);

% Store it in a results object:
R = results(res,{'ldc' 'qdc' 'knnc' 'parzenc' 'svc'}, ...
   {'data1','iris','ionosphere','dat4'}, 5);
% Set the dimension names:
R = setdimname(R,'classifiers','datasets','runs');
% Set the results name:
R = setname(R,'AUC performances');

% Average over the runs:
T = average(10*R,3);

% And... show it! in text:
show(T,'text');
show(T,'latex');
show(T,'html');
% or in a graph:
figure(1); clf; show(T,'bar');
figure(2); clf; show(T,'surf');
figure(3); clf; show(T,'graph');

