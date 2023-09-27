% test_v2_Classification_CrossValidateMulti_opt.m
% ---------------------------
% Testing expected successful and unsuccessful calls to crossValidateMulti_opt.m.

% Nathan - Aug 26, 2019; Edited by Ray April, 2022
clear all; close all; clc

run('loadUnitTestData.m');

RSA = MatClassRSA;


%% Test default input parameters, 3D data, 6-class labels -- looks good
% default classifier should be LDA
% default rng should be ('shuffle', 'twister')
% default PCA should be .99
% default PCAinFold should be 0
% nFolds 10

C = RSA.Classification.crossValidateMulti_opt(S01.X, S01.labels6);
C.classificationInfo

%% Test default input parameters, 3D data, 6-class labels, rng -- looks good
% default classifier should be SVM
% default PCA should be .99
% default PCAinFold should be 0
% nFolds 3
% setting {0,'twister'} for rng. This should be the same as "default"
% kernel set to 'linear', should not have a gamma hyperparameter

M = RSA.Classification.crossValidateMulti_opt(S01.X, S01.labels6, 'rngType', {0,'twister'}, 'nFolds', 3, 'classifier', 'SVM');
M.classificationInfo

%% Test default input parameters, 3D data, 6-class labels, rng -- looks good
% default classifier should be LDA
% default PCA should be .99
% default PCAinFold should be 0
% nFolds 10
% setting {0,'twister'} for rng. This should be the same as "default"

M = RSA.Classification.crossValidateMulti_opt(S01.X, S01.labels6, 'rngType', {4,'twister'}, 'nFolds', 4);
M.classificationInfo;



%%
M = RSA.Classification.crossValidatePairs(S01.X, S01.labels6);
M.classificationInfo;
%% test PCA = 0, 72 class -- ERROR
M2 = RSA.Classification.crossValidateMulti(S01.X, S01.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar

%% test PCA = 0, 6 class -- looks good
M2 = RSA.Classification.crossValidateMulti(S01.X, S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar


%% Test generic classify cross-validate, with specified name-value pairs, LDA, 3D, 6-class lables
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

M = RSA.Classification.crossValidateMulti( S01.X , S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);


%%  Test string input for Y vector -- looks good 
% Throws "Warning: Y label vector not in double format. Converting Y labels to double."
% Y is converted to [97 97 98 98 99 99]
    
M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , ['a' 'a' 'b' 'b' 'c' 'c'], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);
%%  Test multi-character string input for Y vector -- fails 
% Throws "Warning: Y label vector not in double format. Converting Y labels to double."
% Each character is converted to a double.
% Here Y is converted to [66 65 76 79 67 66 78 77 80 84 82 77]
    
M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , ['BA', 'LO', 'CB', 'NM', 'PT', 'RM'], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);

%%  Test multi-character string input as cell array for Y vector -- fails 
% Throws "Warning: Y label vector not in double format. Converting Y labels to double."
% 'Cell array cannot be converted to double'
    
M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , {'BA', 'LO', 'CB', 'NM', 'PT', 'RM'}, ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);


%%  Test label order -- looks good
M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , [9 9 25 25 2 2], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);

%%  Test label negative number -- looks good
M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , [-9 -9 25 25 2 2], ...
    'classifier', 'LDA', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);

%%  Test decimal labels -- fails as expected

M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , [1 1 2 2 3.1 3.1], ...
    'classifier', 'RF', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);

%%  Test decimal labels as strings -- runs without error, but fails
% Throws "Warning: Y label vector not in double format. Converting Y labels to double."
% However each character is converted to a double.
% Here Y is converted to [49 49 59 59 51 46 49 51 46 49]

M = RSA.Classification.crossValidateMulti( SL100.X(1:6, :) , ['1' '1' '2' '2' '3.1' '3.1'], ...
    'classifier', 'RF', ...
    'PCA', 0.9, ...
    'nFolds', 3, ...
    'rngType', 1 ...
);

%% Test Random Forest 2D input -- looks good
M_CC = RSA.Classification.crossValidateMulti( SL100.X , SL100.Y, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

%% Test LDA 2D input -- looks good
M_CC = RSA.Classification.crossValidateMulti( SL100.X , SL100.Y, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);
%% Test SVM 2D input, without hyperparameters -- looks good
% Throws message indicating that hyperparameters must be specified
M_CC = RSA.Classification.crossValidateMulti( SL100.X , SL100.Y, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

%% Test Random Forest 3D input, 6-class lables -- looks good
M_CC = RSA.Classification.crossValidateMulti( S01.X , S01.labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

%% Test SVM 3D input, without hyperparameters -- looks good
% Throws message indicating that hyperparameters must be specified
M_CC = RSA.Classification.crossValidateMulti( S01.X , S01.labels6, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

%% Test RF 3D input, with numTrees > 128 -- looks good
% classifies better than default (128), as expected

M_CC = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'numTrees', 200 ...
);
%% Test RF 3D input, with numTrees < 128 -- looks good
% doesn't classify as well as default (128), as expected

M_CC = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'numTrees', 50 ...
);
%% Test LDA 3D input, with numTrees specified -- looks good
% no issue

M_1 = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'numTrees', 200 ...
);
%% Test PCA set to 1.0 -- looks good

M_2 = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 1.0, ...
    'nFolds', 3 ...
);

%% Test PCA set to 1.1 -- looks good

M_3 = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 1.1, ...
    'nFolds', 3 ...
);

%% Test RF, with permutations -- fail
% returns pVal of 0
% accuracy:0.1865
M_CC = RSA.Classification.crossValidateMulti(S01.X , S01.labels6, ...
    'classifier', 'RF', ...
    'PCA', 0.99, ...
    'nFolds', 3, ...
    'numTrees', 50, ...
    'permutations', 5 ...
);

%% Test LDA, 3D Data, 72-class labels -- looks good
M = RSA.Classification.crossValidateMulti(S01.X, S01.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy

%% Test LDA, 3D Data, 6-class labels, slightly unbalanced -- looks good
M = RSA.Classification.crossValidateMulti(S01_6class_slightlyUnbalanced.X, S01_6class_slightlyUnbalanced.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

%% Test LDA, 3D Data, 6-class labels, very unbalanced -- looks good
M = RSA.Classification.crossValidateMulti(S01_6class_veryUnbalanced.X, S01_6class_veryUnbalanced.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar
%% Test LDA, 3D Data, 72-class labels, slightly unbalanced -- looks good
M = RSA.Classification.crossValidateMulti(S01_72class_slightlyUnbalanced.X, S01_72class_slightlyUnbalanced.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar


%% Test LDA, 3D Data, 72-class labels, very unbalanced -- looks ok
M = RSA.Classification.crossValidateMulti(S01_72class_veryUnbalanced.X, S01_72class_veryUnbalanced.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

%% Test LDA, 3D Data, 72-class labels, low count -- looks ok
M = RSA.Classification.crossValidateMulti(S01_72class_lowCountUnbalanced.X, S01_72class_lowCountUnbalanced.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

%% Test LDA, 3D Data, 6-class labels, low count -- looks ok
M = RSA.Classification.crossValidateMulti(S01_6class_lowCountUnbalanced.X, S01_6class_lowCountUnbalanced.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
);

M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

%% Test before and after Preprocessing 3D Input: Noise Normalization -- ERROR with array exceding maximum array size
[Xnorm, sigma] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);
M = RSA.Classification.crossValidateMulti(S01.X, S01.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

%"Error using zeros. Requested 2897x2897x2556 (159.8GB) array exceeds maximum array size preference (64.0GB). This might cause MATLAB to become
% unresponsive"
%% Test before and after Preprocessing 3D Input 6-class: Noise Normalization -- 
[Xnorm, sigma] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels6);
M = RSA.Classification.crossValidateMulti(Xnorm, S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
imagesc(M.CM)
colorbar

M2 = RSA.Classification.crossValidateMulti(Xnorm, S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M.CM)
colorbar
%% Test before and after Preprocessing 2D Input: Noise Normalization -- Doesn't Classify well at all
[Xnorm, sigma] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);
M = RSA.Classification.crossValidateMulti(Xnorm, SL100.Y, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar


M2 = RSA.Classification.crossValidateMulti(SL100.X, SL100.Y, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar

%% Test before and after Preprocessing 72-class: Averaging -- averaging with, makes classification way worse

[Xavg, Yavg] = RSA.Preprocessing.averageTrials(S01.X, S01.labels72, 5);

M = RSA.Classification.crossValidateMulti(Xavg, Yavg, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

M2 = RSA.Classification.crossValidateMulti(S01.X, S01.labels72, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar

%% Test before and after Preprocessing 6-class: Averaging -- averaging with, makes classification way worse

[Xavg, Yavg] = RSA.Preprocessing.averageTrials(S01.X, S01.labels6, 5);

M = RSA.Classification.crossValidateMulti(Xavg, Yavg, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

M2 = RSA.Classification.crossValidateMulti(S01.X, S01.labels6, ...
    'classifier', 'LDA', ...
    'PCA', 0.99, ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar

%% Test before and after Preprocessing, without PCA: Averaging -- makes classification worse
[Xavg, Yavg] = RSA.Preprocessing.averageTrials(S01.X, S01.labels72, 5);
M = RSA.Classification.crossValidateMulti(Xavg, Yavg, ...
    'classifier', 'LDA', ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

M2 = RSA.Classification.crossValidateMulti(S01.X, S01.labels72, ...
    'classifier', 'LDA', ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar


%% Test SL100 averaged vs SL500  -- 
[Xavg, Yavg] = RSA.Preprocessing.averageTrials(SL100.X, SL100.Y, 5, SL100.P);
M = RSA.Classification.crossValidateMulti(Xavg, Yavg, ...
    'classifier', 'LDA', ...
    'nFolds', 3 ...
    );
M.classificationInfo
M.accuracy
figure
imagesc(M.CM)
colorbar

M2 = RSA.Classification.crossValidateMulti(SL500.X, SL500.Y, ...
    'classifier', 'LDA', ...
    'nFolds', 3 ...
    );
M2.classificationInfo
M2.accuracy
figure
imagesc(M2.CM)
colorbar
%%
M3 = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 1000);
C = classifyPredict( M_CC.modelsConcat{3}, X_2D(3457:end, :),  labels6( 3457:end));
figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');


