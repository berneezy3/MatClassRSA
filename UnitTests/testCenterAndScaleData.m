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