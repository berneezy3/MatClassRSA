% example_Classification_trainMulti.m
% -----------------------------------
% Example function calls for trainMulti() function within
% the +Classification module
%
% This example requires one or more example data files. Run the 
% illustrative_0_downloadExampleData script in the IllustrativeAnalyses 
% folder if you have not already downloaded the example data. 

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

%% 3D data, 6-class labels, default parameters
% default classifier should be LDA
% default PCA should be .99
% default PCAinFold should be 0
% default nFolds 10

M = Classification.trainMulti(X, labels6);
M.classificationInfo

%% Reproducible RNG, Single-Argument

M = Classification.trainMulti(X, labels6, 'rngType', 3);
M.classificationInfo

%% Reproducible RNG, Dual-Argument

M = Classification.trainMulti(X, labels6, 'rngType', {rngSeed,'twister'});
M.classificationInfo

%% Number of Folds of Cross-Validation

M = Classification.trainMulti(X, labels6, 'rngType', {rngSeed,'twister'}, 'nFolds', 4);
M.classificationInfo


%% No Principle Component Analysis
M = Classification.trainMulti(X, labels6, ...
    'classifier', 'LDA', ... % same as default
    'rngType', {rngSeed,'twister'},...
    'PCA', 0);

M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

%% Specify Described Variance by Principle Components 

M = Classification.trainMulti(X , labels6, ...
    'classifier', 'LDA', ... % same as default
    'PCA', 0.99, ...
    'rngType', rngSeed ...
);

M.classificationInfo

%% Number of Permutations

M = Classification.trainMulti(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'permutations', 5 ...
);

M.classificationInfo

%% PCA within Cross-Validation Folds
% PCAinFold default is 0 (false)

M = Classification.trainMulti(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'PCAinFold', 1);

M.classificationInfo

%% Time Use

% Innspect time vector
t(17:22)

% We pass in the array 17:23 into the 'timeUse' argument to 
% subset data representing 144-224 milliseconds.   
M = Classification.trainMulti(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 17:22);

M.classificationInfo


%% Space Use

% We pass in the array 94:100 into the 'spaceUse' argument to 
% subset data representing electrodes 94 to 100.   
M = Classification.trainMulti(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 94:100);

M.classificationInfo


%% Turning Centering Off

% Default centering - true

M = Classification.trainMulti(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'center', false);

M.classificationInfo


%% Scaling on

% Default scaling - false

M = Classification.trainMulti(X, labels6, 'PCA', .99, ...
    'classifier', 'LDA', 'scale', true);

M.classificationInfo

%% Random Forest Classification, Default Hyperparameters
% default numTrees = 128
% default minLeafSize = 1

M_RF = Classification.trainMulti(X , labels6, ...
    'classifier', 'RF', ...
    'rngType', rngSeed,...
    'PCA', 0.99);

M_RF.classificationInfo

%% Random Forest Hyperparameters: Number of Trees

M = Classification.trainMulti(X , labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'numTrees', 200 ...
);
M.classificationInfo

%% Random Forest Hyperparameters: Leaf Size

M = Classification.trainMulti(X , labels6, ...
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
% See trainMulti_opt.m example script

gamma_opt = .0032;
C_opt = 100000;

M = Classification.trainMulti(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'gamma', gamma_opt, 'C', C_opt ...
);

M.classificationInfo
%% Support Vector Machine Classification: Linear Kernel
% Hyperparameters identified by grid search, must be specified by user. 
% 'C' is the hyperparameter of SVM's linear kernel. 
% C_opt was computed using Classification.crossVailidateMulti_opt()
% See trainMulti_opt.m example script

C_opt = 100000;

M = Classification.trainMulti(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear', ...
    'C', C_opt ...
);

M.classificationInfo

%% Feature Use

load('losorelli_100sweep_epoched.mat')

% We pass in the array of chosen features into the 
% 'featureUse' argument to subset data representing features of interest.   
M = Classification.trainMulti(X, Y, 'PCA', .99, ...
    'classifier', 'LDA', 'featureUse', 100:1500);

M.classificationInfo



