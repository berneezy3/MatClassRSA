% example_Visualization_plotMDS.m
% ---------------------
% Ray - May, 2025
%
% Example function calls for plotMDS() function within
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
Visualization.plotMDS(RDM)
%% Adding Nodes

figure;
Visualization.plotMDS(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6);
%% Changing Dimensions of MDS Plot

figure;
Visualization.plotMDS(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'dimensions', [1 3]);
%% Changing X and Y Limit

figure;
Visualization.plotMDS(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'dimensions', [2 3], 'xLim', [-0.2 1], 'yLim', [-0.5 0.8]);
%% Non-classical MDS Scaling

figure;
Visualization.plotMDS(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'dimensions', [2 3], 'xLim', [-0.2 1], 'yLim', [-0.5 0.8], 'classical',0);
