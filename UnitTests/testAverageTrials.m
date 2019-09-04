% testAverageTrials.m
% ---------------------
% Nathan - Aug 15, 2019
%
% Testing expected successful and unsuccessful calls to averageTrials.m.
%
% TODO: Not sure how to test the averaging yet.
%   This one still needs work

clear all; close all; clc

rng('shuffle')
nTrial = 1000;
nSpace = 10;
nTime = 20;

X_3D = rand(nSpace, nTime, nTrial);
X_2D = rand(nTrial, nTime);
P = randi(3, [1 nTrial]);

%% SUCCESS: 3D input data matrix
Y = randi(10, [1 nTrial]);
[x3, y3, p3, o3] = averageTrials(X_3D, Y, 5, P);

% Test that averaged data are as expected
assert(length(y3) == size(o3,1))
for i=1:length(y3)
    averaged = x3(:,:,i);
    to_average = X_3D(:,:,find(ismember(Y,o3(i,:))==1))
    assert(isequal(averaged, mean(to_average,3)));
end

%% SUCCESS: 3D input data matrix, only 1 trial per label and averaging across one trial
% Also testing the same Y dimensions for both input and output. Success.

Y = 1:nTrial; Y = Y';
[x3, y3, ~, o3] = averageTrials(X_3D, Y, 1, 'endShuffle', 0);
assert(isequal(X_3D, x3));
assert(isequal(y3, Y));

%% SUCCESS: Testing different Y dimensions

Y = 1:nTrial;
[x3, y3, ~, ~] = averageTrials(X_3D, Y', 1, 'endShuffle', 0);
assert(isequal(X_3D, x3));
assert(isequal(y3, Y'));

%% SUCCESS: Testing End Shuffling

Y = 1:nTrial;
[x3, y3, ~, ~] = averageTrials(X_3D, Y, 1, 'endShuffle', 1, 'rngType', 0);
assert(isequal(size(X_3D), size(x3)));
assert(isequal(size(y3), size(Y)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y3(i);
    assert(isequal(X_3D(:,:,idx), x3(:,:,i)));
end

%% SUCCESS: 2D input data matrix with participants vector
Y = randi(10, [1 nTrial]);
[x2, y2, p2, ~] = averageTrials(X_2D, Y, 5, P);

%% SUCCESS: 2D input data matrix, only 1 trial per label and averaging across one trial
Y = 1:nTrial;
[x2, y2, ~, ~] = averageTrials(X_2D, Y, 1, 'endShuffle', 0);
assert(isequal(X_2D, x2));
assert(isequal(y2, Y));

%% SUCCESS: Testing End Shuffling
Y = 1:nTrial;
[x2, y2, ~, ~] = averageTrials(X_2D, Y, 1, 'endShuffle', 1, 'rngType', 0);
assert(isequal(size(X_2D), size(x2)));
assert(isequal(size(y2), size(Y)));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y2(i);
    assert(isequal(X_2D(idx,:), x2(i,:)));
end

%% Check average across participants, also check index vector (BY BERNARD)

nObs = 1000;
nfeat = 1000;
X_2D = rand(nObs, nfeat);
X_2D = [X_2D; rand(1, nfeat)];

% 5 classes
Y = zeros(1, nObs);
Y(1:200) = 1;
Y(201:400) = 2;
Y(401:600) = 3;
Y(601:800) = 4;
Y(801:1000) = 5;
Y = [Y 1];

% 2 participants
P = zeros(1, nObs);
P([1:100, 201:300, 401:500, 601:700, 801:900]) = 1;
P([101:200, 301:400, 501:600, 701:800, 901:1000]) = 2;
P = [P 1]

[x2, y2, p2, whichObs] = averageTrials(X_2D, Y, 20, P, 'endShuffle', 0, 'handleRemainder', 'distribute');
assert(isequal(X_2D, x2));




