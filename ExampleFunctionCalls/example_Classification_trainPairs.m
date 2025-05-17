% example_Classification_trainPairs.m
% -------------------------------------------------------
% Ray - March, 2025
%
% Example function calls for trainPairs() function within
% the +Classification module

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

%% 3D data, 6-class labels, default parameters
% default classifier should be LDA
% default PCA should be .99
% default PCAinFold should be 0


M = Classification.trainPairs(X, labels6);
M.classificationInfo{1}

%% Reproducible RNG, Single-Argument

M = Classification.trainPairs(X, labels6, 'rngType', rngSeed);
M.classificationInfo{1}

%% Reproducible RNG, Dual-Argument

M = Classification.trainPairs(X, labels6, 'rngType', {rngSeed,'twister'});
M.classificationInfo{1}

%% No Principle Component Analysis
M = Classification.trainPairs(X, labels6, ...
    'classifier', 'LDA', ... % same as default
    'rngType', {rngSeed,'twister'},...
    'PCA', 0);

M.classificationInfo{1}

%% Specify Described Variance by Principle Components 

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'LDA', ... % same as default
    'PCA', 0.99, ...
    'rngType', rngSeed ...
);

M.classificationInfo{1}

%% Number of Permutations, and Random Forest Classifier

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'permutations', 5 ...
);

M.classificationInfo{1}


%% Time Use

% Innspect time vector
t(17:22)

% We pass in the array 17:23 into the 'timeUse' argument to 
% subset data representing 144-224 milliseconds.   
M = Classification.trainPairs(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 17:22);

M.classificationInfo{1}


%% Space Use

% We pass in the array 94:100 into the 'spaceUse' argument to 
% subset data representing electrodes 94 to 100.   
M = Classification.trainPairs(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 94:100);

M.classificationInfo{1}


%% Turning Centering Off

% Default centering - true

M = Classification.trainPairs(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'center', false);

M.classificationInfo{1}


%% Scaling on

% Default scaling - false

M = Classification.trainPairs(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'scale', true);

M.classificationInfo{1}


%% Random Forest Classification, Default Hyperparameters
% default numTrees = 128
% default minLeafSize = 1

M_RF = Classification.trainPairs(X , labels6, ...
    'classifier', 'RF', ...
    'rngType', rngSeed,...
    'PCA', 0.99);

M_RF.classificationInfo{1}

%% Random Forest Hyperparameters: Number of Trees

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'numTrees', 200 ...
);
M.classificationInfo{1}

%% Random Forest Hyperparameters: Leaf Size

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'minLeafSize',2 ...
);
M.classificationInfo{1}

%% Support Vector Machine Classification: RBF Kernel
% Default SVM kernel is rbf
% Hyperparameters identified by grid search, must be specified by user. 
% 'gamma' and 'C' are hyperparameters of SVM's rbf kernel. gamma_opt and 
% C_opt were computed using Classification.trainPairs_opt()
% See trainMulti_opt.m example script

gamma_opt = .0032;
C_opt = 100000;

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'gamma', gamma_opt, 'C', C_opt ...
);

M.classificationInfo{1}
%% Support Vector Machine Classification: Linear Kernel
% Hyperparameters identified by grid search, must be specified by user. 
% 'C' is the hyperparameter of SVM's linear kernel. 
% C_opt was computed using Classification.trainPairs_opt()
% See trainMulti_opt.m example script

C_opt = 100000;

M = Classification.trainPairs(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear', ...
    'C', C_opt ...
);

M.classificationInfo{1}

%% Feature Use

load('losorelli_100sweep_epoched.mat')

% We pass in the array of chosen features into the 
% 'featureUse' argument to subset data representing features of interest.   
M = Classification.trainPairs(X, Y, 'PCA', .99, ...
    'classifier', 'LDA', 'featureUse', 100:1500);

M.classificationInfo{1}
