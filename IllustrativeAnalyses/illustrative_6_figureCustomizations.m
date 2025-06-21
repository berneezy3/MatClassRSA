% Illustrative_6_figureCustomizations.m
% -----------------------------------------
% Illustrative example code visualizing 
% This scripts call functions from +Preprocessing, +Classification,
% +RDM_Computation, and +Visualization modules.
%
% This script covers the following steps:
%  - Setup Workspace


% Ray - May, 2025
%%% Clear workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 3;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat')


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
%% Confusion Matrix Visualization

% Change as needed
iconpath = './6ClassStim/';

% ---------------------- Preprocessing Steps -------------------------
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'handleRemainder', ...
    'newGroup', 'rngType', rnd_seed);  % Apply group averaging


% ---------------------------- Classification ----------------------------
M = Classification.crossValidateMulti(xAvg, yAvg, 'classifier', 'LDA', 'PCA', 0.99);


figure;
Visualization.plotMatrix(M.CM, 'colorbar', 0, ...
                            'colorMap', 'summer', ...
                            'matrixLabels', 1);
                        
% Remove default ticks
set(gca, 'XTick', [], 'YTick', []);

% Offset for placing the images
offset = 0.5;  

N = length(stimImages);

% Clear default tick labels but keep ticks in place
set(gca, 'XTick', 1:length(stimImages), 'XTickLabel', []);
set(gca, 'YTick', 1:length(stimImages), 'YTickLabel', []);

fig = gcf;
fig.Units = 'normalized';
fig.Position = [0.1 0.1 0.7 0.8];  % Wider and taller than default

mainAx = gca;
colorbar(mainAx);  
mainAx = gca;
mainPos = get(mainAx, 'Position');
mainPos(2) = mainPos(2) + 0.1 * mainPos(4);  % Shift matrix up slightly
mainPos(4) = mainPos(4) * 0.85;              % Slightly reduce height
mainPos(1) = mainPos(1) + 0.07;  % increase this if needed
mainPos(3) = mainPos(3) * 0.92;  % optional: slightly reduce width to maintain fit
set(mainAx, 'Position', mainPos);


mainPos = get(mainAx, 'Position');
N = length(stimImages);

for i = 1:N
    ax = axes('Position', [ ...
        mainPos(1) + (i - 1) * mainPos(3)/N, ...  % X position (step across)
        mainPos(2) - mainPos(4)*0.15, ...          % Y position (below matrix)
        mainPos(3)/N, ...                         % Width
        mainPos(4)*0.15]);                        % Height (adjust as needed)
    
    imshow(stimImages{i});
    axis off
end

xlabel(mainAx, 'Predicted Labels', 'Units', 'normalized', 'Position', [0.5, -0.15, 0], 'fontSize', 16, 'FontWeight', 'bold');

% Add stimulus images as y-tick labels
for i = 1:N
    ax = axes('Position', [ ...
        mainPos(1) - mainPos(3)*0.15, ...        % X to the left of matrix
        mainPos(2) + (N - i) * mainPos(4)/N, ... % Y
        mainPos(3)*0.15, ...                     % Width
        mainPos(4)/N]);                          % Height
    imshow(stimImages{i});
    axis off
end

ylabel(mainAx, 'True Labels', ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [-0.15, 0.5, 0]);  % Shift left (x) and center (y)

set(gcf, 'Position', [100,500,250,250]);
title(mainAx, '6-Class Classification on Visual Stimulus Evoked ERP', 'fontSize', 20);

%% Dendrogram  Visualization


RDM = RDM_Computation.computeCMRDM(M.CM);

Visualization.plotDendrogram(RDM);

% Remove default ticks
set(gca, 'XTick', [], 'YTick', []);

% Offset for placing the images
offset = 0.5;  

N = length(stimImages);

% Clear default tick labels but keep ticks in place
set(gca, 'XTick', 1:length(stimImages), 'XTickLabel', []);
set(gca, 'YTick', 1:length(stimImages), 'YTickLabel', []);

fig = gcf;
fig.Units = 'normalized';
fig.Position = [0.1 0.1 0.7 0.8];  % Wider and taller than default

mainAx = gca;

mainPos = get(mainAx, 'Position');
mainPos(2) = mainPos(2) + 0.1 * mainPos(4);  % Shift matrix up slightly
mainPos(4) = mainPos(4) * 0.85;              % Slightly reduce height
mainPos(1) = mainPos(1) + 0.07;  % increase this if needed
mainPos(3) = mainPos(3) * 0.92;  % optional: slightly reduce width to maintain fit
set(mainAx, 'Position', mainPos);


mainPos = get(mainAx, 'Position');
N = length(stimImages);

for i = 1:N
    ax = axes('Position', [ ...
        mainPos(1) + (i - 1) * mainPos(3)/N, ...  % X position (step across)
        mainPos(2) - mainPos(4)*0.15, ...          % Y position (below matrix)
        mainPos(3)/N, ...                         % Width
        mainPos(4)*0.15]);                        % Height (adjust as needed)
    
    imshow(stimImages{i});
    axis off
end

xlabel(mainAx, 'Stimuli', 'Units', 'normalized', 'Position', [0.5, -0.15, 0], 'fontSize', 16, 'FontWeight', 'bold');



title(mainAx, '6-Class Classification on Visual Stimulus Evoked ERP', 'fontSize', 20);