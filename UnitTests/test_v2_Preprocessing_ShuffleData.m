% testShuffleData.m
% ---------------------
% Blair - Aug 9, 2019
% Nathan - Aug 15, 2019
% Ray - Feb, 2022
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

% Add the following datasets to "UnitTests" folder: "lsosorelli_100sweep_epoched.mat",
% "lsosorelli_500sweep_epoched.mat","S01.mat"
run('loadUnitTestData.m') 


%% SUCCESS: 3D input data matrix
[x3, y3, p3, rndIdx] = Preprocessing.shuffleData(X_3D, Y, P);
assert(isequal(size(x3), size(X_3D)));
assert(isequal(size(y3), size(Y)));
assert(isequal(size(p3), size(P)));
assert(isequal(P(rndIdx), p3));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y3(i);
    assert(isequal(X_3D(:,:,idx), x3(:,:,i)));
    %disp("Success");
end

%This felt a little hacky..... i need someone to check my work on the
%shuffleData.m script. Lines 129-139. Here i changed the nargin values to
%reflect the implicit obj as argument. But I also had to
%replace P with ip.Results.P. As P is defined explicitly as an input
%parameter
%% SUCCESS: 2D input data matrix
[x2, y2, p2, rndIdx] = Preprocessing.shuffleData(X_2D, Y, P);
assert(isequal(size(x2), size(X_2D)))
assert(isequal(size(y2), size(Y)));
assert(isequal(size(p2), size(P)));
assert(isequal(P(rndIdx), p2));

% Check to make sure the values match after the shuffling
% We know that Y should contain the indices of the shuffling
for i=1:nTrial
    idx = y2(i);
    assert(isequal(X_2D(idx,:), x2(i,:)));
end

%% SUCCESS: Testing P functionality on real dataset
[x_shuf, y_shuf, p_shuf, rndIdx] = Preprocessing.shuffleData(SL100.X, SL100.Y, SL100.P);

assert(isequal(SL100.P(rndIdx), p_shuf));

%% SUCCESS: Testing 3D 6 class labels balanced 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01.X, S01.labels6);
assert(isequal(size(xShuf,3), size(yShuf,2)))


h1 =histcounts(S01.labels6);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01.labels6));

%% SUCCESS: Testing 3D 6 class labels slightly unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_6class_slightlyUnbalanced.X, S01_6class_slightlyUnbalanced.labels6);


h1Dist=histcounts(S01_6class_slightlyUnbalanced.labels6);

h2Dist =histcounts(yShuf);


assert(isequal(h1Dist, h2Dist));
assert(isequal(yShuf, S01_6class_slightlyUnbalanced.labels6));

%% SUCCESS: Testing 3D 6 class labels very unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_6class_veryUnbalanced.X, S01_6class_veryUnbalanced.labels6);

h1 =histcounts(S01_6class_veryUnbalanced.labels6);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01_6class_veryUnbalanced.labels6));

%% SUCCESS: Testing 3D 6 class labels low count unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_6class_lowCountUnbalanced.X, S01_6class_lowCountUnbalanced.labels6);

h1 =histcounts(S01_6class_lowCountUnbalanced.labels6);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01_6class_lowCountUnbalanced.labels6));

%% SUCCESS: Testing 3D 72 class labels balanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01.X, S01.labels72);

h1 =histcounts(S01.labels72);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01.labels72));

%% SUCCESS: Testing 3D 72 class labels slightly unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_72class_slightlyUnbalanced.X, S01_72class_slightlyUnbalanced.labels72);

h1 =histcounts(S01_72class_slightlyUnbalanced.labels72);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01_72class_slightlyUnbalanced.labels72));

%% SUCCESS: Testing 3D 72 class labels very unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_72class_veryUnbalanced.X, S01_72class_veryUnbalanced.labels72);

h1 =histcounts(S01_72class_veryUnbalanced.labels72);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01_72class_veryUnbalanced.labels72));

%% SUCCESS: Testing 3D 72 class labels low count unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(S01_72class_lowCountUnbalanced.X, S01_72class_lowCountUnbalanced.labels72);

h1 =histcounts(S01_72class_lowCountUnbalanced.labels72);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, S01_72class_lowCountUnbalanced.labels72));

%% SUCCESS: Testing 2D balanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(SL100.X, SL100.Y);

h1 =histcounts(SL100.Y);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, SL100.Y));

%% SUCCESS: Testing 2D slightly unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(SL100_slightlyImbalanced.X, SL100_slightlyImbalanced.Y);

h1 =histcounts(SL100_slightlyImbalanced.Y);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, SL100_slightlyImbalanced.Y));

%% SUCCESS: Testing 2D very unbalanced, 2 outputs only, no participants, no user specified randomization

[xShuf, yShuf] = Preprocessing.shuffleData(SL100_veryImbalanced.X, SL100_veryImbalanced.Y);

h1 =histcounts(SL100_veryImbalanced.Y);
h2 =histcounts(yShuf);

assert(isequal(h1, h2));
assert(isequal(yShuf, SL100_veryImbalanced.Y));

%% SUCCESS: Testing random seed set '1'
rng(1);
xrtest = X_2D(randperm(nTrial),:);

[xr, yr, ~] = Preprocessing.shuffleData(X_2D, Y, P, 'rngType', 1);
assert(isequal(xrtest, xr));

%requires name-value pairing to work... for example
%Preprocessing.shuffleData(X_2D, Y, P, 1); will not work here. This
%seems like it is not the case elsewhere.

%% SUCCESS: Testing random seed set 'default'
rng('default');
xrtest = X_2D(randperm(nTrial),:);

[xr, yr, ~] = Preprocessing.shuffleData(X_2D, Y, P, 'rngType', 'default');
assert(isequal(xrtest, xr));

%requires name-value pairing to work... for example
%Preprocessing.shuffleData(X_2D, Y, P, 1); will not work here. This
%seems like it is not the case elsewhere.

%% FAIL: Testing random seed set 'shuffle'
rng('shuffle');
xrtest = X_2D(randperm(nTrial),:);

[xr, yr, ~] = Preprocessing.shuffleData(X_2D, Y, P, 'rngType', 'shuffle');
assert(isequal(xrtest, xr));

%requires name-value pairing to work... for example
%Preprocessing.shuffleData(X_2D, Y, P, 1); will not work here. This
%seems like it is not the case elsewhere.


%% SUCCESS: Testing return NaN if nargin < 3 or P not specified
rng('shuffle')
[~, ~, pr] = Preprocessing.shuffleData(X_3D, Y);
assert(isnan(pr))

[~, ~, pr] = Preprocessing.shuffleData(X_3D, Y, []);
assert(isnan(pr))
