% crossValidateMulti.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for crossValidateMulti() function within
% the +Classification module

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

%% 3D data, 6-class labels, default parameters
% default classifier should be LDA
% default PCA should be .99
% default PCAinFold should be 0
% default nFolds 10

M = Classification.crossValidateMulti(X, labels6);
M.classificationInfo

%% Reproducible RNG, Single-Argument

M = Classification.crossValidateMulti(X, labels6, 'rngType', 3);
M.classificationInfo

%% Reproducible RNG, Dual-Argument

M = Classification.crossValidateMulti(X, labels6, 'rngType', {rngSeed,'twister'});
M.classificationInfo

%% Number of Folds of Cross-Validation

M = Classification.crossValidateMulti_opt(X, labels6, 'rngType', {rngSeed,'twister'}, 'nFolds', 4);
M.classificationInfo


%% No Principle Component Analysis
M = Classification.crossValidateMulti(X, labels6, ...
    'classifier', 'LDA', ... % same as default
    'rngType', {rngSeed,'twister'},...
    'PCA', 0);

M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

%% Specify Described Variance by Principle Components 

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'LDA', ... % same as default
    'PCA', 0.99, ...
    'rngType', rngSeed ...
);

M.classificationInfo

%% Random Forest Classification, Default Hyperparameters
% default numTrees = 128
% default minLeafSize = 1

M_RF = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'RF', ...
    'rngType', rngSeed,...
    'PCA', 0.99);

M_RF.classificationInfo

%% Random Forest Hyperparameters: Number of Trees

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'numTrees', 200 ...
);
M.classificationInfo

%% Random Forest Hyperparameters: Leaf Size

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'minLeafSize',2 ...
);
M.classificationInfo

%% Support Vector Machine Classification: RBF Kernel
% Default SVM kernel is rbf
% Hyperparameters identified by grid search, must be specified by user. 
% 'gamma' and 'C' are hyperparameters of SVM's rbf kernel. gamma_opt and 
% C_opt were computed using Classification.crossVailidateMulti_opt()
% See crossValidateMulti_opt.m example script

gamma_opt = .0032;
C_opt = 100000;

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'gamma', gamma_opt, 'C', C_opt ...
);

M.classificationInfo
%% Support Vector Machine Classification: Linear Kernel
% Hyperparameters identified by grid search, must be specified by user. 
% 'C' is the hyperparameter of SVM's linear kernel. 
% C_opt was computed using Classification.crossVailidateMulti_opt()
% See crossValidateMulti_opt.m example script

C_opt = 100000;

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear', ...
    'C', C_opt ...
);

M.classificationInfo
%% Number of Permutations

M = Classification.crossValidateMulti(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'permutations', 5 ...
);

M.classificationInfo
%% Feature Use
%% Time Use
%% Space Use
%% PCA within Cross-Validation Folds

