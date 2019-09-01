% testNoiseNormalization.m
% ----------------------------
% Blair - 1 Sep 2019
%
% I'm not completely sure how to check that this is working correctly
%
% TODO: Add a bit more info in the docstring as to which implementation
% described in Guggenmos is used (is it MNN (not UNN) with the epoch
% method?)
% TODO: I get an error at line 52 if a 2D matrix is input. Does it even
% make sense to attempt noise normalization when we have only 1 channel of
% data, where there is no "error covariance between different sensors" to
% be considered? I wonder if the function should state outright that it
% only works on multi-channel data that are input with the specified 3D
% shape...

clear all; close all; clc

nTrial = 1000;
nSpace = 124;
nTime = 40;

X2 = rand(nTrial, nTime);
X3 = rand(nSpace, nTime, nTrial);
Y = randi(5, [nTrial 1]);

%% SUCCESS: Call the function with 3D input matrix
clc
[a3, b3] = noiseNormalization(X3, Y);

%% SUCCESS?? Call the function with 2D input matrix
clc
[a2, b2] = noiseNormalization(X2, Y);

%% FAIL: Call the function with wrong-length labels vector
clc
[a, b] = noiseNormalization(X3, Y(1:(end-1)));

% Error using noiseNormalization (line 35)
% Length of labels vector does not match number of trials in the
% data.

%% FAIL: Labels is not a vector
clc
[a, b] = noiseNormalization(X2, X2);