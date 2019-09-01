% testAverageTrials.m
% ---------------------
% Nathan - Aug 15, 2019
%
% Testing expected successful and unsuccessful calls to averageTrials.m.

% TODO: How do you add P into the input of function call?
%   You should be able to add it as a 4th input, before any name-value
%   pairs
% TODO: Not sure how to test the averaging yet.
%   This one still needs work
% TODO: The outputted Y vector is a column vector (input Y is row vector)
%   The function now checks if Y and P are rows or columns (P is
%   initialized to be the same shape as Y if it is not specified) and to
%   return each vector in the same shape as input. Please check for each of
%   those variables independently.

clear all; close all; clc

rng('shuffle')
nTrial = 200;
nSpace = 10;
nTime = 20;

X_3D = rand(nSpace, nTime, nTrial);
X_2D = rand(nTrial, nTime);
P = randi(5, [1 nTrial]);

%% SUCCESS: 3D input data matrix
Y = randi(10, [1 nTrial]);
[x3, y3, ~] = averageTrials(X_3D, Y, 5);

%% SUCCESS: 3D input data matrix, only 1 trial per label and averaging across one trial
Y = 1:nTrial;
[x3, y3, ~] = averageTrials(X_3D, Y, 1, 'endShuffle', 0);
assert(isequal(X_3D, x3));
assert(isequal(y3', Y));

%% SUCCESS: Testing End Shuffling
Y = 1:nTrial;
[x3, y3, ~] = averageTrials(X_3D, Y, 1, 'endShuffle', 1, 'rngType', 0);
assert(isequal(size(X_3D), size(x3)));
assert(isequal(size(y3'), size(Y)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y3(i);
    assert(isequal(X_3D(:,:,idx), x3(:,:,i)));
end

%% SUCCESS: 2D input data matrix
Y = randi(10, [1 nTrial]);
[x2, y2, ~] = averageTrials(X_2D, Y, 5);

%% SUCCESS: 2D input data matrix, only 1 trial per label and averaging across one trial
Y = 1:nTrial;
[x2, y2, ~] = averageTrials(X_2D, Y, 1, 'endShuffle', 0);
assert(isequal(X_2D, x2));
assert(isequal(y2', Y));

%% SUCCESS: Testing End Shuffling
Y = 1:nTrial;
[x2, y2, ~] = averageTrials(X_2D, Y, 1, 'endShuffle', 1, 'rngType', 0);
assert(isequal(size(X_2D), size(x2)));
assert(isequal(size(y2'), size(Y)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y2(i);
    assert(isequal(X_2D(idx,:), x2(i,:)));
end



