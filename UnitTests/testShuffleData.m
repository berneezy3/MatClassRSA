% testShuffleData.m
% ---------------------
% Blair - Aug 9, 2019
%
% Testing expected successful and unsuccessful calls to shuffleData.m.

clear all; close all; clc

rng('shuffle')
nTrial = 10;

%% SUCCESS: 3D input data matrix


Y = 1:nTrial;
P = 101:110;

%% SUCCESS: 2D input data matrix


%% SUCCESS: Testing random seed set
rng(1)
xrtest = X(randperm(10),:);
[xr, yr, pr] = shuffleData(X, Y, P, 1);
assert(isequal(xrtest, xr));

%% SUCCESS: Testing return NaN if nargin < 3 or P not specified
rng('shuffle')
[~, ~, pr] = shuffleData(X, Y);
assert(isnan(pr))

[~, ~, pr] = shuffleData(X, Y, []);
assert(isnan(pr))