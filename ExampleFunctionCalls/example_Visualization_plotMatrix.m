% example_Visualization_plotMatrix.m
% ---------------------
% Ray - May, 2025
%
% Example function calls for plotMatrix() function within
% the +Visualization module

clear all; close all; clc;

load('S06.mat');
rngSeed = 3;

% Preprocessing steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 30, 'handleRemainder', 'newGroup', 'rngType', rngSeed);  % Apply group averaging

% Classify with LDA
M = Classification.crossValidateMulti(xAvg, yAvg, 'PCA', .99, ...
   'classifier', 'LDA', 'rngType', rngSeed);

% Define Confusion Matrix
CM = M.CM;

% Compute Confusion Matrix RDM
RDM = RDM_Computation.computeCMRDM(M.CM);

% create cell array to store colors for visualization
rgb6 = {[0.1216    0.4667    0.7059],  ...  % Blue
    [1.0000    0.4980    0.0549] ,     ...  % Orange
    [0.1725    0.6275    0.1725] ,     ...  % Green
    [0.8392    0.1529    0.1569]  ,    ...  % Red
    [0.5804    0.4039    0.7412]  ,    ...  % Purple
    [0.7373    0.7412    0.1333]};          % Chartreuse

% create category label names
%   HB = Human Body
%   HF = Human Face
%   AB = Animal Body
%   AF = Animal Face
%   FV = Fruit / Vegetable
%   IO = Inanimate Object
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};

%% Basic Function Call

Visualization.plotMatrix(CM)
%% Adding Axis Labels to CM Matrix Plot, with Colorbar

figure;
Visualization.plotMatrix(CM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6);

%% Adding Axis Labels to RDM with Rank

figure;
Visualization.plotMatrix(RDM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'r');
%% Adding Matrix Labels to RDM with Displayed Percent Rank

figure;
Visualization.plotMatrix(RDM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'p', 'matrixLabels', 1);

%% Change Colormap

figure;
Visualization.plotMatrix(RDM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'p', 'matrixLabels', 1, 'colorMap', 'copper');
%% Change Font Size

figure;
Visualization.plotMatrix(CM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'p', 'matrixLabels', 1, 'colorMap', 'copper', 'fontSize', 20);

%% Change Colorbar Ticks

figure;
Visualization.plotMatrix(CM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'p', 'matrixLabels', 1, 'colorMap', 'winter', 'ticks', 10);
%% Changing Text Rotation

figure;
Visualization.plotMatrix(CM, 'colorbar', 1,  ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'ranktype', 'p', 'matrixLabels', 1, 'colorMap', 'summer', 'ticks', 10, 'textRotation', 20);
