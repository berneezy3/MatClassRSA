% testShuffleData.m
% ---------------------
% Blair - Aug 9, 2019
% Nathan - Aug 15, 2019
%
% Testing expected successful and unsuccessful calls to shuffleData.m.

clear all; close all; clc

rng('shuffle')
nTrial = 100;
nSpace = 10;
nTime = 20;

X_3D = rand(nSpace, nTime, nTrial);
X_2D = rand(nTrial, nTime);
Y = 1:nTrial;
P = randi(5, [1 nTrial]);

%% SUCCESS: 3D input data matrix
[x3, y3, p3] = shuffleData(X_3D, Y, P);
assert(isequal(size(x3), size(X_3D)));
assert(isequal(size(y3), size(Y)));
assert(isequal(size(p3), size(P)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y3(i);
    assert(isequal(X_3D(:,:,idx), x3(:,:,i)));
end

%% SUCCESS: 2D input data matrix
[x2, y2, p2] = shuffleData(X_2D, Y, P);
assert(isequal(size(x2), size(X_2D)))
assert(isequal(size(y2), size(Y)));
assert(isequal(size(p2), size(P)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y2(i);
    assert(isequal(X_2D(idx,:), x2(i,:)));
end

%% SUCCESS: Testing random seed set
rng(1);
xrtest = X_2D(randperm(nTrial),:);

[xr, yr, ~] = shuffleData(X_2D, Y, P, 1);
assert(isequal(xrtest, xr));

%% SUCCESS: Testing return NaN if nargin < 3 or P not specified
rng('shuffle')
[~, ~, pr] = shuffleData(X_3D, Y);
assert(isnan(pr))

[~, ~, pr] = shuffleData(X_3D, Y, []);
assert(isnan(pr))



