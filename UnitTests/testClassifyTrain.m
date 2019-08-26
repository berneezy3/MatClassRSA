% testClassifyTrain.m
% ---------------------
% Nathan - Aug 26, 2019
%
% Testing expected successful and unsuccessful calls to classifyTrain.m.
% Only checking for successful runs.  Not checking output values.

clear all; close all; clc

rng('shuffle');

% S06.mat should be in UnitTests directory
load('S06.mat');
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

%% Run classification for 2D data using LDA and predict with random seed
% Runs successfully.

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);

%% Run classification for 3D data using LDA
% Runs successfully.

M = classifyTrain( X(:, :, 1:floor(dim3/5)) , labels6(1:floor(dim3/5)), 'classifier', 'LDA', 'PCA', 0);

%% Run classification for 3D data using LDA and timeUse
% Runs successfully.
% Issue:
%    Minor: why is M.trainingDataSize = [124,40,1036]. Technically, if I
%    set 'timeUse' to 1:30, the trainingDataSize = [124,30,1036] right?
%    Implementation looks fine though, I think.

M = classifyTrain( X(:, :, 1:floor(dim3/5)) , labels6(1:floor(dim3/5)), 'timeUse', 1:30, 'classifier', 'LDA', 'PCA', 0);

%% Run clasification for 3D data using LDA and spaceUse
% Runs successfully
% Issue:
%    Minor: why is M.trainingDataSize = [124,40,1036]. Technically, if I
%    set 'spaceUse' to 1:120, the trainingDataSize = [120,40,1036] right?
%    Implementation looks fine though, I think.

M = classifyTrain( X(:, :, 1:floor(dim3/5)) , labels6(1:floor(dim3/5)), 'spaceUse', 1:120, 'classifier', 'LDA', 'PCA', 0);

%% Run classification for 2D data using SVM and RBF kernel
% Issues:
%   - Error using classifyTrain (line 198)
%       The value of 'kernel' is invalid. Undefined function or variable 'expectedKernels'.
%
%   - Although {'PCA', 0} is set, PCA is still run:
%       Conducting Principal Component Analysis...
%       got 681 PCs

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 0);

%% Run classification for 2D data using SVM and PCA with 100 components without setting kernel
% Runs successfully (doing PCA)

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'SVM', 'PCA', 100);

%% Run classification for 2D data using random forest with default and custom hyperparameters
% Runs successfully.
% Issue:
%    - Minor: Should we add numTrees and minLeafSize to the classifierInfo
%      struct, so users know what hyperparameters were set?  I guess the
%      same goes for the LDA and SVM.

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'RF', 'PCA', 0);
M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), ...
        'classifier', 'RF', ...
        'PCA', 0, ...
        'numTrees', 100, ...
        'minLeafSize', 4 ...
    );






