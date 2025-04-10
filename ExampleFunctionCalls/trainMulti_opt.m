% trainMulti_opt.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for trainMulti_opt() function within
% the +Classification module

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

%% 3D data, 6-class labels, default parameters
% default classifier should be SVM
% default PCA should be .99
% default PCAinFold should be 0
% default nFolds 10
% default kernel is rbf

% you can expect this to take a long time to complete

M = Classification.trainMulti_opt(X, labels6);
M.classificationInfo

%% Reproducible RNG, Single-Argument

M = Classification.trainMulti_opt(X, labels6, 'rngType', rngSeed);
M.classificationInfo

%% Reproducible RNG, Dual-Argument

M = Classification.trainMulti_opt(X, labels6, 'rngType', {rngSeed,'twister'});
M.classificationInfo

%% Number of Folds of Cross-Validation

M = Classification.trainMulti_opt(X, labels6, 'rngType', {rngSeed,'twister'}, 'nFolds', 2);
M.classificationInfo


%% No Principle Component Analysis
M = Classification.trainMulti_opt(X, labels6, ...
    'rngType', {rngSeed,'twister'},...
    'PCA', 0);

M.classificationInfo

%% Specify Described Variance by Principle Components 

M = Classification.trainMulti_opt(X , labels6, ...
    'PCA', 0.99, ...
    'rngType', rngSeed ...
);

M.classificationInfo

%% Number of Permutations

M = Classification.trainMulti_opt(X , labels6, ...
    'PCA', 0.99, ...
    'permutations', 5 ...
);

M.classificationInfo

%% PCA within Cross-Validation Folds
% PCAinFold default is 0 (false)

M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
    'PCAinFold', 1);

M.classificationInfo

%% Time Use

% Innspect time vector
t(17:22)

% We pass in the array 17:23 into the 'timeUse' argument to 
% subset data representing 144-224 milliseconds.   
M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
    'timeUse', 17:22);

M.classificationInfo
M.accuracy

%% Space Use

% We pass in the array 94:100 into the 'spaceUse' argument to 
% subset data representing electrodes 94 to 100.   
M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
    'spaceUse', 94:100);

M.classificationInfo


%% Turning Centering Off

% Default centering - true

M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
   'center', false);

M.classificationInfo

%% Scaling on

% Default scaling - false

M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'scale', true);

M.classificationInfo

%% Linear Kernel
% Hyperparameters identified by grid search, must be specified by user. 
% 'C' is the hyperparameter of SVM's linear kernel. 
% C_opt was computed using Classification.crossVailidateMulti_opt()
% See crossValidateMulti_opt_opt.m example script

M = Classification.trainMulti_opt(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear'...
);

M.classificationInfo

%% Feature Use on 2D data

load('losorelli_100sweep_epoched.mat')

% We pass in the array of chosen features into the 
% 'featureUse' argument to subset data representing features of interest.   
M = Classification.trainMulti_opt(X, Y, 'PCA', .99, ...
    'featureUse', 100:1500);

M.classificationInfo

