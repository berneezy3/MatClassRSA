% example_Visualization_plotMST.m
% -------------------------------
% Example function calls for plotMST() function within
% the +Visualization module
%
% This example requires one or more example data files. Run the 
% illustrative_0_downloadExampleData script in the IllustrativeAnalyses 
% folder if you have not already downloaded the example data. 

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
Visualization.plotMST(RDM)
%% Adding Nodes

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6);
%% Changing Dimensions of MDS Plot

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6);
%% Changing Edge Label Size

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'edgeLabelSize', 10);

%% Changing Node Label Size

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 25);

%% Changing Node Label Size

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 28, 'nodeLabelRotation', 30);

%% Changing Line Width

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 28, 'lineWidth', 3);

%% Changing Line Color

figure;
Visualization.plotMST(RDM, 'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 28, 'lineColor', rgb6{1}, 'lineWidth', 3);
