% illustrative_5_compareRDMs.m
% -----------------------------------------
% Illustrative example code visualizing various RMD constructs within the toolkit
% This scripts call functions from +Preprocessing, +Classification,
% +RDM_Computation, and +Visualization modules.
%
% This script covers the following steps:
%  - Setup Workspace
%  - Multi-class vs Pairwise Classification RDM 
%  - Compare Pearson and Euclidean RDMs At Electrode
%  - Compare Pearson and Euclidean RDMs At Timepoint

% Ray - May, 2025

%% Setup Workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 4;

% Load three dimensional datasets (electrode x time X trial),
% from the same study
load('S06.mat');

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
catLabelsElaborate = {'Human Body', 'Human Face', 'Animal Body', ...
    'Animal Face', 'Fruit / Vegetable', 'Inanimate Object'};

%% Multi-class vs Pairwise Classification

% ---------------------- Preprocessing Steps ---------------------------
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 20, 'handleRemainder', ...
    'newGroup', 'rngType', rnd_seed);  % Apply group averaging

% ---------------------------- Training -------------------------------

% Multi-class LDA Classification
MMC = Classification.crossValidateMulti(xAvg, yAvg, ...
    'classifier', 'LDA', 'PCA', 0.99);

% Pairwise LDA Classification
MPW = Classification.crossValidatePairs(xAvg, yAvg, ...
    'classifier', 'LDA', 'PCA', 0.99);


% ------------------------- RDM Computation ------------------------------

% Multi-class RDM from confusion matrix
[RDMmc, params] = RDM_Computation.computeCMRDM(MMC.CM);

% Pairwise RDM from accuracy matrix
RDMpm = RDM_Computation.shiftPairwiseAccuracyRDM(MPW.AM);


% -------------------------- Visualization ------------------------------
figure;
set(gcf, 'Position', [150,300,1200,1200]);
subplot(3,2,1);
Visualization.plotMatrix(RDMmc, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6, ...
                            'colorMap', 'summer', 'rankType', 'p');
 
title(sprintf('Multi-class Classification RDM'));
set(gca, 'fontsize', 16);

subplot(3,2,2);
Visualization.plotMatrix(RDMpm, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6, ...
                            'colorMap', 'summer', 'rankType', 'p');
                        
title(sprintf('Pairwise Classification RDM'));
set(gca, 'fontsize', 16);

subplot(3,2,3);
Visualization.plotMDS(RDMmc, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Multi-class Classification MDS'));
set(gca, 'fontsize', 16);

subplot(3,2,4);
Visualization.plotMDS(RDMpm, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Pairwise Classification MDS'));
set(gca, 'fontsize', 16);

subplot(3,2,5);
Visualization.plotDendrogram(RDMmc, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Multi-class Classification Dendrogram'));
set(gca, 'fontsize', 16);

subplot(3,2,6);
Visualization.plotDendrogram(RDMpm, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Pairwise Classification Dendrogram'));
set(gca, 'fontsize', 16);


sgtitle('Multi-class vs Pairwise Classification on Same Dataset', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

annotation ('textbox', [0.45, 0.32, 0.1, 0.1], ...
    'String', sprintf('Pairwise classification may be more sensitive to class similarities, which drive confusion in classifcation'),...
    'FontSize', 18, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

%% Compare Pearson and Euclidean RDMs At Electrode
singleElectrodeX = squeeze(X(96,:,:));

PearsonRDM = RDM_Computation.computePearsonRDM(singleElectrodeX, labels6, ...
    'rngType', rnd_seed);

EuclidRDM = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels6, ...
    'rngType', rnd_seed);

% -------------------------------- Plot ---------------------------------
figure;
set(gcf, 'Position', [150,300,1200,1200]);
subplot(2,2,1)
Visualization.plotMatrix(PearsonRDM.RDM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'colorMap', 'summer', 'rankType', 'p');
 
title(sprintf('Pearson RDM'));
set(gca, 'fontsize', 16)

subplot(2,2,2)
Visualization.plotMatrix(EuclidRDM.RDM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'colorMap', 'summer', 'rankType', 'p');
                        
title(sprintf('Euclidean RDM'));
set(gca, 'fontsize', 16)

subplot(2,2,3)
Visualization.plotMST(PearsonRDM.RDM, ...
    'nodeLabels', catLabels, 'nodeColors', rgb6);
 
title(sprintf('Pearson MST'));
set(gca, 'fontsize', 16)

subplot(2,2,4)
Visualization.plotMST(EuclidRDM.RDM, ...
    'nodeLabels', catLabels, 'nodeColors', rgb6);

title(sprintf('Euclidean MST'));
set(gca, 'fontsize', 16)

sgtitle('Single Electrode 96, Computed Pearson and Euclidean RDM', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');
%% Compare Pearson and Euclidean RDMs At Timepoint

% Visualize selected timepoint of interest
figure();
set(gcf, 'Position', [10,600,500,500]);

for i = 1:6
    
    % Subset out the data for the current stim category
    % time x trials
    temp = squeeze(xAvg(96, :, yAvg==i));
    
    % Plot current mean and color by category
    % We take the mean across the 2nd (trial) dimension
    % Color the mean black and use a larger linewidth
    plot(t, mean(temp,2), 'color', rgb6{i},...
        'linewidth', 2);
    
    hold on
    
    % Our aesthetics from before
    grid on
    xlabel('Time (msec)'); ylabel('Voltage (\muV)')
    
    xlim([-112 512])
    set(gca, 'fontsize', 16)
    
    % Get current axis limits
    xLimits = xlim;
    yLimits = ylim;
      
end

% Draw line at timepoint of interest
xline(t(17), '--k', 'LineWidth', 1.5);
title('Electrode 96, 6-Class ERPs Averaged across Trials');
set(gca, 'fontsize', 16)

% Add legend
legendTemp = catLabelsElaborate;
legendTemp{end+1} = 'Timepoint selected';
legend(legendTemp);

% Subset data at time point of interest
singleTimePointX = squeeze(X(:,17,:));

% ---------------------------- Compute RDMs --------------------------------
PearsonRDM = RDM_Computation.computePearsonRDM(singleTimePointX, labels6, ...
    'rngType', rnd_seed);

EuclidRDM = RDM_Computation.computeEuclideanRDM(singleTimePointX, labels6, ...
    'rngType', rnd_seed);

% ------------------------------ Plot -------------------------------
figure;
set(gcf, 'Position', [150,300,1100,1100]);
subplot(3,2,1)
Visualization.plotMatrix(PearsonRDM.RDM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'colorMap', 'summer', 'rankType', 'p');
 
title(sprintf('Pearson RDM'));
set(gca, 'fontsize', 16)

subplot(3,2,2)
Visualization.plotMatrix(EuclidRDM.RDM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6, 'colorMap', 'summer', 'rankType', 'p');
                        
title(sprintf('Euclidean RDM'));
set(gca, 'fontsize', 16)

subplot(3,2,3)
Visualization.plotMDS(RDMmc, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Pearson MDS'));
set(gca, 'fontsize', 16)

subplot(3,2,4)
Visualization.plotMDS(RDMpm, 'nodeLabels', catLabels, 'nodeColors', rgb6);
                        
title(sprintf('Euclidean MDS'));
set(gca, 'fontsize', 16)

subplot(3,2,5)
Visualization.plotMST(PearsonRDM.RDM, ...
    'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 28, ...
    'lineColor', rgb6{1}, 'lineWidth', 3);
 
title(sprintf('Pearson MST'));
set(gca, 'fontsize', 16)

subplot(3,2,6)
Visualization.plotMST(EuclidRDM.RDM, ...
    'nodeLabels', catLabels, 'nodeColors', rgb6, 'nodeLabelSize', 28, ...
    'lineColor', rgb6{1}, 'lineWidth', 3);

title(sprintf('Euclidean MST'));
set(gca, 'fontsize', 16)

sgtitle('Single Timepoint (144 ms), Visualized Pearson and Euclidean RDM', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');
