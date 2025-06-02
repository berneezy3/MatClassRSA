% example_Visualization_plotDendrogram.m
% ---------------------
% Ray - May, 2025
%
% Example function calls for plotDendrogram() function within
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

figure;
Visualization.plotDendrogram(RDM)
%% Adding Nodes

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6);
%% Changing Font Size of Node Labels

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 10);
%% Changing Order of Classes

% specify new order of classes to display 
order = [4,5,6,1,2,3];

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 25, 'reorder', order);
%% Changing Text Rotation

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 25, 'textRotation', 20);
%% Changing Y Limit

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 25, 'textRotation', 20, 'yLim', [0.8 1]);
%% Changing Line Width

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 25, 'textRotation', 20, 'yLim', [0.8 1], 'lineWidth', 3);
%% Changing Line Color

figure;
Visualization.plotDendrogram(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'fontSize', 25, 'textRotation', 20, 'yLim', [0.8 1], 'lineWidth', 2.5, 'lineColor', rgb6{1});

