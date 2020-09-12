% scratch__dataScalingJan2020.m
% -----------------------------
% Blair - Jan 9, 2020
%
% Looking at how to best implement data scaling prior to SVM
% classification.

clear all; close all; clc

load S06.mat
XNN = noiseNormalization(X, labels6);

%% Classify with no scaling

C_svm_5 = classifyCrossValidate(X, labels6, 'classifier', 'SVM',... 
    'nFolds', 5, 'randomSeed', 1);
% Accuracy = 16.38%; crap CM

C_svm_5_NN = classifyCrossValidate(XNN, labels6, 'classifier', 'SVM',...
    'nFolds', 5, 'randomSeed', 1);
% Accuracy = 36.84%; CM is not crap but performance is not great

C_lda_5 = classifyCrossValidate(X, labels6, 'classifier', 'LDA',... 
    'nFolds', 5, 'randomSeed', 1);
% Accuracy = 50.14%; CM is reasonable

C_lda_5_NN = classifyCrossValidate(XNN, labels6, 'classifier', 'LDA',... 
    'nFolds', 5, 'randomSeed', 1);
% Accuracy = 53.36%; CM is reasonable

%% Quick implementation: Scale all data at once. 

% Later, should scale training data only and apply it to the test data in
% each fold.

X_sc01 = scaleDataMinMax(X, [0 1]);
X_sc11 = scaleDataMinMax(X, [-1 1]);
XNN_sc01 = scaleDataMinMax(XNN, [0 1]);
XNN_sc11 = scaleDataMinMax(XNN, [-1 1]);

% START HERE
% ----------------------------
% PCs are messed up when doing this! BUT WHY DOES PCA ACT NORMAL WHEN I
% SCALE THE 2D MATRIX AND THEN INPUT IT TO CLASSIFYCROSSVALIDATE AND ASK IT
% TO DO PCA IN THERE???
% I think we need zero-mean data for SVD-based PCA
% So scaling to [-1 1] will be more stable 

%% Quick implementation: PCA, then scaling on all data at once

X_pc = getPCs(cube2trRows(X), 0.9);
XNN_pc = getPCs(cube2trRows(XNN), 0.9);

X_sc01 = scaleDataMinMax(X_pc, [0 1]);
X_sc11 = scaleDataMinMax(X_pc, [-1 1]);
XNN_sc01 = scaleDataMinMax(XNN_pc, [0 1]);
XNN_sc11 = scaleDataMinMax(XNN_pc, [-1 1]);

%% Classify quick-scaled data

C_sc01_svm_5 = classifyCrossValidate(X_sc01, labels6, 'classifier', 'SVM',... 
    'nFolds', 5, 'randomSeed', 1, 'PCA', 0.999999999999);
C_sc11_svm_5 = classifyCrossValidate(X_sc11, labels6, 'classifier', 'SVM',... 
    'nFolds', 5, 'randomSeed', 1, 'PCA', 0.999999999999);

%%

%%% By-hand partition into 5 folds %%%
% Here are the trial indices for each fold
part5 = {(1:1037)', (1038:2074)', (2075:3111)', (3112:4148)', (4149:5184)'};
allIdx = 1:5184;

