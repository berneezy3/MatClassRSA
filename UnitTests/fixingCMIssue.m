
clear all; close all; clc

rng('shuffle');

% S06.mat should be in UnitTests directory
load('S06.mat');


[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';
[r c] = size(X_2D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% compare these values w/ classifyCrossValidate()

M_split = classifyTrain( X_2D(1:3456, :) , labels6(1:3456), 'classifier', 'SVM', 'PCA', .9, 'kernel', 'rbf');
C = classifyPredict( M_split, X_2D(3457:end, :),  labels6( 3457:end));
figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%%

classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'PCAinFold', 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

M3 = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 1000);
C3 = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3));
figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');
%%
M4 = classifyCrossValidate(X_scaled, labels6, 'classifier', 'SVM', 'nFolds', 5)
%%
M5_lin = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 5, 'kernel', 'linear')
%%
M6 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 3, 'PCA', 0.9)
%%
MLDA3 = classifyCrossValidate(X_2D, labels6, 'classifier', 'LDA', 'nFolds', 3, 'PCA', 0.9)
%%
MRF3 = classifyCrossValidate(X_2D, labels6, 'classifier', 'RF', 'nFolds', 5)
%%
M8 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 4, 'PCA', 0.9)
%%
M9 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 9)
%%
M88 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 8)
%%
M5 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 10)
%%
M15 = classifyCrossValidate(X_scaled, labels6, 'classifier', 'SVM', 'nFolds', 15)
%%
M12 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 12)
%%
M2 = classifyCrossValidate(X_2D, labels6, 'classifier', 'SVM', 'nFolds', 2)
%%
M0 = classifyCrossValidate(X_2D, labels6)
%%
M02 = classifyCrossValidate(X_2D, labels6', 'PCA', .9)

%%
M5_channel96 = classifyCrossValidate(X, labels6', 'PCA', .9, 'spaceUse', 96)
%%
M5_channel96 = classifyCrossValidate(X, labels6', 'classifier', 'LDA', 'PCA', .9, 'spaceUse', 96)
%%
M5_PCA2 = classifyCrossValidate(X, labels6', 'PCA', .9, 'spaceUse', 96, 'nFolds', 5)