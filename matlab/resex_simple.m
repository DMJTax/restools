%RESEX_SIMPLE basic example script
%
% This script should show how a results-object can be created, and how
% to make nice tables and figures form it.

% Generate (not completely random) results to show:
m = repmat((1:10)'/10,[1,4,5]);
res = m + 0.4*rand(10,4,5);

% Define the values of the different dimensions:
dim1 = {'cl1','cl2','cl3','cl4','cl5','cl6',...
   'cl7','cl8','cl9','cl10'};
dim2 = {'data1','iris','ionosphere','dat4'};
dim3 = (1:5)';

% Store it in a results object:
R = results(res,dim1,dim2,dim3);
% Set the dimension names:
R = setdimname(R,'classifiers','datasets','runs');
% Set the results name:
R = setname(R,'AUC performances');

% Average over the runs:
T = average(10*R,3);
% And... show it! in text:
show(T)

