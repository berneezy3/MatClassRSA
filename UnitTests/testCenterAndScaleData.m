% testPlotMatrix.m
% ---------------------
% Blair/Bernard - April 5, 2020
%
% Testing data centering and scaling for PCA

clear all; close all; clc

load('losorelli_500sweep_epoched.mat');
x100 = X + 100;
%% Add 100 to Data Matrix, don't center, and classify.  
% We expect the classification to perform poorly in this case.


C_plus100nocenter = classifyCrossValidate(x100, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', false);
C_plus100nocenter
figure
plotMatrix(C_plus100nocenter.CM)
title(' + 100 w/o data centering')
colorbar

%% Add 100 to Data Matrix, center, and classify.  
% The classification should perform well now

C_plus100center = classifyCrossValidate(x100, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true);
C_plus100center
figure
plotMatrix(C_plus100center.CM)
title(' + 100 w/ data centering')
colorbar

%% Add 100 to Data Matrix, center AND SCALE, and classify.  
% The classification should perform well now

C_plus100center = classifyCrossValidate(x100, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true, 'scale', true);
C_plus100center
C_plus100center = classifyCrossValidate(X + 100, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true);
C_plus100center = classifyCrossValidate(X + 100 , Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true);
figure
plotMatrix(C_plus100center.CM)
title(' + 100 w/ data centering')
colorbar


%% Classification and prediction with 2D data using LDA
% Issue related to the random seed:
%    - Although the confusion matrices are the same for both runs, the
%      C.predY and C1.predY vectors are different.
%      ### BERNARD UPDATE:  C.predY and C1.predY should now be equal ###

[dim1, dim2] = size(X);
trainData = X(1:floor(2 * dim1/3), :);
trainLabels = Y(1:floor(2 * dim1/3));
testData = X(floor(2 * dim1/3)+1:dim1, :);
testLabels = Y(floor(2 * dim1/3)+1:dim1);

M = classifyTrain( trainData +100 , trainLabels, 'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1, 'center', true);
C = classifyPredict( M, testData + 100,  testLabels, 'randomSeed', 1);

figure; 
plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');


