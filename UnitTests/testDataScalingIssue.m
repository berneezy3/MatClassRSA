% testClassifyPredict.m
% ---------------------
% Bernard - March 1st, 2019
%
% Testing expected successful and unsuccessful calls to classifyPredict.m.

clear all; close all; clc

rng('shuffle');

% S06.mat should be in UnitTests directory
load('S06.mat');

%%
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

%% Classification and prediction with 2D data using SVM
% Issues:
%    - Output CM does not make any sense 
%    - Already stated in testClassifyTrain.m, but even though {'PCA', 0} is
%      set, PCA is being run.  However, if we do not input the kernel
%      name-value pair, PCA is not run (which is expected). (FIXED)
%    - Error using classifyPredict (line 103)
%      Expected a string for the parameter name, instead the input type was 'double'.

M_split = classifyTrain( X_2D(1:end-518, :) , labels6(1:end-518), 'classifier', 'SVM', 'PCA', .9, 'kernel', 'rbf');
C = classifyPredict( M_split, X_2D(end-517:end, :),  labels6( end-517:end));

figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%%

M4 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 10, 'PCAinFold', 0)
