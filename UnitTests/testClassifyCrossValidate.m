% testClassifyCrossValidate.m
% ---------------------
% Nathan - Aug 26, 2019
%
% Testing expected successful and unsuccessful calls to classifyCrossValidate.m.

clear all; close all; clc

rng('shuffle');

% S06.mat should be in UnitTests directory
load('s06.mat');
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';
RSA = MatClassRSA;
Y = labels6;

%% Test default input parameters
% default classifier should be LDA
% default PCA should be .99
% default PCAinFold should be 0

M = RSA.classify.crossValidateMulti(X, Y);


%% Run generic classify cross-validate
% Issue:
%
% Error using classreg.learning.FullClassificationRegressionModel.prepareDataCR (line 176)
% X and Y do not have the same number of observations.
% 
% Error in classreg.learning.classif.FullClassificationModel.prepareData (line 473)
%                 classreg.learning.FullClassificationRegressionModel.prepareDataCR(...
% 
% Error in classreg.learning.FitTemplate/fit (line 206)
%                     this.PrepareData(X,Y,this.BaseFitObjectArgs{:});
% 
% Error in ClassificationDiscriminant.fit (line 104)
%             this = fit(temp,X,Y);
% 
% Error in fitcdiscr (line 141)
% this = ClassificationDiscriminant.fit(X,Y,varargin{:});
% 
% Error in fitModel (line 57)
%             mdl = fitcdiscr(X, Y, 'DiscrimType', 'linear');
% 
% Error in classifyCrossValidate (line 478)
%             mdl = fitModel(trainX, trainY, ip);
% 
% Error in testClassifyCrossValidate (line 21)
% M = classifyCrossValidate( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), ...
%
% Set a breakpoint at line 478 in classifyCrossValidate.m and you see that
% the data matrix sizes are different.  It looks like the train and test
% set partitioning resulted in data sets of different sizes.

M = RSA.classify.crossValidateMulti( X , Y, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'randomSeed', 1 ...
);

%%  test string DOES NOT WORK
M = RSA.classify.crossValidateMulti( X_2D(1:6, :) , ['a' 'a' 'b' 'b' 'c' 'c'], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'randomSeed', 1 ...
);

%%  test label order
M = RSA.classify.crossValidateMulti( X_2D(1:6, :) , [9 9 25 25 2 2], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'randomSeed', 1 ...
);

%%  test decimal labels
nanX_2D = X_2D(1:6, :);
nanX_2D(1, 1) = NaN;

M = RSA.classify.crossValidateMulti( nanX_2D(1:6, :) , [1 1 2 2 3.1 3.1], ...
    'classifier', 'RF', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'randomSeed', 1 ...
);
%%
M_CC = RSA.classify.crossValidateMulti( X_2D , Y, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

%%

M3 = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 1000);
C = classifyPredict( M_CC.modelsConcat{3}, X_2D(3457:end, :),  labels6( 3457:end));
figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');


