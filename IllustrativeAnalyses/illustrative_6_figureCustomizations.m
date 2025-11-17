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
mainAx = gca;
hold(mainAx, 'on');

N = length(stimImages);

% ---------------- Plot ----------------

yl = get(mainAx,'YLim');
xl = get(mainAx,'XLim');

% Determine direction of Y
if strcmp(get(mainAx,'YDir'), 'reverse')
    rowCenter = @(i) i;          % top = 1
else
    rowCenter = @(i) N - i + 1;  % top = N
end


% Image width and height
imgHeight = 0.8;   
imgWidth  = 0.8;   

% X location to the left of the confusion matrix
xLeft = xl(1) - imgWidth - 0.1; 

for i = 1:N
    yc = rowCenter(i);            
    yBottom = yc - imgHeight/2;
    yTop    = yc + imgHeight/2;
    image(mainAx, [xLeft, xLeft + imgWidth], [yBottom, yTop], stimImages{i}, ...
        'Clipping', 'off');
end

% Prevent autoscaling
set(mainAx, 'YLim', yl, 'XLim', xl);

% Compute the bottom row Y coordinate:

bottomY = yl(1);
if strcmp(get(mainAx,'YDir'),'reverse')
    bottomY = yl(2);
end

% Image height (small)
imgHeightX = 0.8;
imgOffset = -0.8;

for i = 1:N
    % match the column width
    xLeftCol  = i - 0.4;
    xRightCol = i + 0.4;

    % below the matrix
    yBottom = bottomY - imgOffset - imgHeightX;
    yTop    = bottomY - imgOffset;

    image(mainAx, [xLeftCol, xRightCol], [yBottom, yTop], stimImages{i}, ...
        'Clipping', 'off');
end

set(mainAx, 'XTick', [], 'YTick', []);

ylabel(mainAx, 'True Labels', ...
    'FontSize', 22, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [-0.15, 0.5, 0]);

fig = gcf;
fig.Units = 'normalized';
fig.Position = [0.1, 0.1, 0.8, 0.9];  

mainPos = get(mainAx, 'Position'); 

mainPos(2) = mainPos(2) + 0.1;    
mainPos(4) = mainPos(4) - 0.1;  
set(mainAx, 'Position', mainPos);

% Move axes right and shrink width
mainPos(1) = mainPos(1) + 0.1;     
mainPos(3) = mainPos(3) - 0.1;    

set(mainAx, 'Position', mainPos);

xlabel(mainAx, 'Predicted Labels', 'Units', 'normalized', 'Position', ...
    [0.5, -0.15, 0], 'fontSize', 22, 'FontWeight', 'bold');

title(mainAx, '6-Class Confusion Matrix', ...
    'fontSize', 26);

c = colorbar(mainAx);
c.FontSize = 22;
c.TickLabelInterpreter = 'none';


%% MDS Visualization

RDM = RDM_Computation.computeCMRDM(M.CM);

Visualization.plotMDS(RDM);

% Assume stimImages is a cell array of image matrices
axMDS = gca;
hold on

% Get the axis limits to convert coordinates to normalized figure units
xRange = xlim(axMDS);
yRange = ylim(axMDS);

for i = 1:size(coords,1)
    % Convert from data to normalized figure position
    xNorm = (coords(i,1) - xRange(1)) / diff(xRange);
    yNorm = (coords(i,2) - yRange(1)) / diff(yRange);

    % Define a small axes for each image
    imgSize = 0.06;  % adjust for scale
    axImg = axes('Position', [xNorm - imgSize/2, yNorm - imgSize/2, imgSize, imgSize]);

    imshow(stimImages{i});
    axis off
end

axes(axMDS);  % Restore focus to the main plot
