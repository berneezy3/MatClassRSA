% example_Classification_trainMulti_opt.m
% ---------------------------------------
% Example function calls for trainMulti_opt() function within
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

% Default scaling: false

M = Classification.trainMulti_opt(X, labels6, 'PCA', .99, ...
    'classifier', 'SVM', 'scale', true);

M.classificationInfo

%% Linear Kernel
% optimizing C hyperparameter for linear kernel

M = Classification.trainMulti_opt(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear'...
);

M.classificationInfo

%% Train/Development and Testing Split
% default is [.9, .1]

M = Classification.trainMulti_opt(X , labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'kernel', 'linear', 'trainDevSplit', [0.8, 0.2] ...
);

M.classificationInfo

%% Feature Use on 2D data

load('losorelli_100sweep_epoched.mat')

% We pass in the array of chosen features into the 
% 'featureUse' argument to subset data representing features of interest.   
M = Classification.trainMulti_opt(X, Y, 'PCA', .99);

M.classificationInfo

