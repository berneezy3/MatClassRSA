% testNoiseNormalization.m
% ----------------------------
% Blair - 1 Sep 2019
% Ray - Feb, 2022
%
% I'm not completely sure how to check that this is working correctly
%
% TODO: Add a bit more info in the docstring as to which implementation
% described in Guggenmos is used (is it MNN (not UNN) with the epoch
% method?)
%
% TODO: I get an error at line 52 if a 2D matrix is input. Does it even
% make sense to attempt noise normalization when we have only 1 channel of
% data, where there is no "error covariance between different sensors" to
% be considered? I wonder if the function should state outright that it
% only works on multi-channel data that are input with the specified 3D
% shape...

clear all; close all; clc;

% Add the following datasets to "UnitTests" folder: "lsosorelli_100sweep_epoched.mat",
% "lsosorelli_500sweep_epoched.mat","S01.mat"
run('loadUnitTestData.m') 

RSA = MatClassRSA;


%% SUCCESS: Call the function with 3D input matrix
clc
[a3, b3] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);

%% SUCCESS Call the function with 2D input matrix
clc
[a2, b2] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);

%% FAIL: Call the function with wrong-length labels vector
clc
[a, b] = RSA.Preprocessing.noiseNormalization(S01.X, S01_72class_slightlyUnbalanced.labels72);

% Error using noiseNormalization (line 35)
% Length of labels vector does not match number of trials in the
% data.

%% FAIL: Labels is not a vector
clc
[a, b] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.X);
%'Y' is not a vector

%% SUCCESS 3D input single channel
[a3d1, b3d1] = RSA.Preprocessing.noiseNormalization(S01.X(96,:,:), S01.labels72);

%% SUCCESS 2D input
X2d = squeeze(S01.X(96,:,:))';
[a2d1, b2d1] = RSA.Preprocessing.noiseNormalization(X2d, S01.labels72);
assert(isequal(squeeze(a3d1), a2d1'))
disp('success! 3d single-channel input equals 2d input')

%% Comparing values in 2D case

unique(X2d ./ a2d1)

%% SUCCESS: Using 3D Normalization outputs as X and Y inputs for subsequent processes (Shuffle)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);
[Xshuff, Yshuff] = RSA.Preprocessing.shuffleData(Xnorm, Ynorm);

%'Y' is invalid. It must satisfy the function: isvector.

%% SUCCESS: Using 3D Normalization outputs as X and Y inputs for subsequent processes (Classify)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);

C_LDA = RSA.Classification.crossValidateMulti(Xnorm, S01.labels72,... 
    'PCA', .99, 'classifier', 'LDA');

%'Y' is invalid. It must satisfy the function: isvector.

%% SUCCESS: Using 3D Normalization outputs as X and Y inputs for subsequent processes (Average)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);

[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(Xnorm, S01.labels72, 5, ... 
    'randomSeed', 0);

%'Y' is invalid. It must satisfy the function: isvector.

%% SUCCESS: Using 2D Normalization outputs as X and Y inputs for subsequent processes (Shuffle)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);
[Xshuff, Yshuff] = RSA.Preprocessing.shuffleData(Xnorm, SL100.Y);

% 'Length of input labels vector must equal length of trial dimension of
% input data.'

%% SUCCESS: Using 2D Normalization outputs as X and Y inputs for subsequent processes (Classify)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);

C_LDA = RSA.Classification.crossValidateMulti(Xnorm, SL100.Y,... 
    'PCA', .99, 'classifier', 'LDA');

% 'Index exceeds the number of array elements (1).'

%% SUCCESS: Using 2D Normalization outputs as X and Y inputs for subsequent processes (Average)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);

[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(Xnorm, SL100.Y, 5, ... 
    'randomSeed', 0);

%'number of trials in X does not equal number of labels in Y'

%% SUCCESS: Using 2D Normalization outputs as X and Y inputs for subsequent processes (Normalization)
[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);
[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(Xnorm, Ynorm);

%number of trials in X does not equal number of labels in Y

%% SUCCESS: Using 3D Normalization outputs as X and Y inputs for subsequent processes (Normalization)

[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);
[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(Xnorm, Ynorm);

%`Y` is not a vector.

%% FAIL: Normalized data being renormalized
clc
[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(S01.X, S01.labels72);
[Xnorm2, Ynorm2] = RSA.Preprocessing.noiseNormalization(Xnorm, S01.labels72);

assert(isequal(Xnorm, Xnorm2))
disp('Success! renormalized data is the same')


%% FAIL: 2D output the same as input
[Xnorm, Ynorm] = RSA.Preprocessing.noiseNormalization(SL100.X, SL100.Y);

assert(isequal(Xnorm, SL100.X.*Ynorm))
disp('Success');

%output is a scaled version of input data. Scaled by factor 'Ynorm'



