% preProcessingOnClassificaiton.m
% -----------------------------------------
% Illustrative example code for implementing and visualizing preprocessing steps
% on classification outputs. This helps to identify the best paramters by which
% to preprocess a dataset classificaiton, using +Preprocessing, +Classification, 
% and +Visualization modules
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Defining class labels and aesthetics
%  - Loading 3D dataset



% Ray - March, 2025

%% Setup Workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 3;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat')

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed.
reliability_time = Reliability.computeSpaceTimeReliability(X, labels72, 'numPermutations', n_perm, 'rngType', rnd_seed);

% a) create cell array to store colors for visualization
rgb6 = {[0.1216    0.4667    0.7059],  ...  % Blue
    [1.0000    0.4980    0.0549] ,     ...  % Orange
    [0.1725    0.6275    0.1725] ,     ...  % Green
    [0.8392    0.1529    0.1569]  ,    ...  % Red
    [0.5804    0.4039    0.7412]  ,    ...  % Purple
    [0.7373    0.7412    0.1333]};          % Chartreuse

% b) create category label names
%   HB = Human Body
%   HF = Human Face
%   AB = Animal Body
%   AF = Animal Face
%   FV = Fruit / Vegetable
%   IO = Inanimate Object
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};
catLabelsElaborate = {'Human Body', 'Human Face', 'Animal Body', ...
    'Animal Face', 'Fruit / Vegetable', 'Inanimate Object'};

% Load 6-class simulus image examples
stim1 = imread('stimulus01.png'); % hand
stim2 = imread('stimulus13.png'); % face
stim3 = imread('stimulus25.png'); % armadillo
stim4 = imread('stimulus37.png'); % cow face
stim5 = imread('stimulus49.png'); % grapes
stim6 = imrotate(imread('stimulus62.png'),90); % lightbulb

% Create iterable image vector
stimImages = {stim1, stim2, stim3, stim4, stim5, stim6};

% Creat iterable image path vector
stimImagePaths = ["stimulus01.png'", "stimulus13.png", "stimulus25.png",...
    "stimulus37.png", "stimulus49.png", "stimulus62.png"];
%% Test group size on accuracy

% Define range of group sizes to test
groupSizes = 50:1000;
numGroupSizes = length(groupSizes);
maxAccuracies = zeros(numGroupSizes, 1); % Store max accuracy for each group size

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
    
% Loop through different group sizes
for g = 1:numGroupSizes
    
    groupSize = groupSizes(g);
    
    try
        [xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, groupSize, 'handleRemainder', 'append');  % Apply group averaging

        % Perform classification after preprocessing
        M = Classification.crossValidateMulti(xAvg(96,19-2:19+8,:), yAvg);  % Run classifier on averaged data

        % Store the accuracy for this group size
        maxAccuracies(g) = M.accuracy;
    catch
        % Store the accuracy for this group size
        maxAccuracies(g) = 0;
    end
end

% Plot max accuracy as a function of group size
figure;
plot(groupSizes, maxAccuracies, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
%%
% Define range of group sizes to test
groupSizes = 1:50;
numGroupSizes = length(groupSizes);
maxAccuracies = zeros(numGroupSizes, 1); % Store max accuracy for each group size

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
    
% Loop through different group sizes
for g = 1:numGroupSizes
    
    groupSize = groupSizes(g);
    
    try
        [xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, groupSize, 'handleRemainder', 'append');  % Apply group averaging

        % Perform classification after preprocessing
        M = Classification.crossValidateMulti(xAvg(96,19-2:19+8,:), yAvg);  % Run classifier on averaged data

        % Store the accuracy for this group size
        maxAccuracies(g) = M.accuracy;
    catch
        % Store the accuracy for this group size
        maxAccuracies(g) = 0;
    end
end

% Plot max accuracy as a function of group size
figure;
plot(groupSizes, maxAccuracies, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
%% interpolate over errors
tempAcc = totalAccuracies(1:75);
v = 1:75;
% Find indices of nonzero and zero elements
x = find(tempAcc ~= 0); % Indices of nonzero values
y = tempAcc(x);         % Nonzero values
xi = find(tempAcc == 0); % Indices of zero values

% Perform interpolation (linear by default)
v(xi) = interp1(x, y, xi, 'linear');
v(x) = y;
%%
% Plot max accuracy as a function of group size
figure;
plot(1:75, v, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
set(gca, 'XScale', 'log');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
