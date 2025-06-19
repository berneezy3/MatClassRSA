% illustrative_3_timeResolvedAnalyses.m
% -----------------------------------------
% Illustrative example code for time-resolved classification,
% identifing the best timepoints for classificaiton, and visualization of
% results, using +Preprocessing, +Reliability, +Classification, and
% +Visualization modules
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Defining class labels and aesthetics
%  - Loading 3D dataset
%  - Computing reliability over time
%  - Computing sliding-window classification over time
%  - Classifcation of 6-Class 3D datasetat, at selected time window
%  - Visualization of classification results

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

% Clear workspace
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

%% Find Reliable Timepoints for 6 and 72 class 3D EEG data

% Run computeSpaceTimeReliability.m with 3D EEG data,
% n_perm permutations and random seed set to rnd_seed.

% 6-class labels vector
reliability_time_6Class = Reliability.computeSpaceTimeReliability(X, labels6, 'numPermutations', n_perm, 'rngType', rnd_seed);

% 72-class labels vector
reliability_time_72Class = Reliability.computeSpaceTimeReliability(X, labels72, 'numPermutations', n_perm, 'rngType', rnd_seed);

% Average reliabilities over space

% 6-class
avg_space_reliability_time_6Class = squeeze(mean(reliability_time_6Class, 1));

% 72-class
avg_space_reliability_time_72Class = squeeze(mean(reliability_time_72Class, 1));

% 6-Class
% Plot the reliability across time, with standard deviation across random
% permutations
figure(1);
subplot(2,2,1);
set(gcf, 'Position', [400,300,950,950]);
plot(t, mean(avg_space_reliability_time_6Class, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(t, mean(avg_space_reliability_time_6Class, 2)+std(avg_space_reliability_time_6Class, [], 2), 'b')
plot(t, mean(avg_space_reliability_time_6Class, 2)-std(avg_space_reliability_time_6Class, [], 2), 'b')
xlim([-150,550]);
ylim([-4,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Avg Reliability Over Electrodes Shown Across Time (+- SD)')
annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        'Data is most reliable ~130 ms - 250 ms'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

text(1, 1.15, '6-Class', 'Units', 'normalized', 'FontSize', 20, 'FontWeight', 'bold');

hold on;

% Most reliable time points
reliableTimePoints = 16:40;
reliableTime = t(:,reliableTimePoints);
spatialAvg_reliableTime = avg_space_reliability_time_6Class(reliableTimePoints,:);

subplot(2,2,2);
plot(reliableTime, mean(spatialAvg_reliableTime, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(reliableTime, mean(spatialAvg_reliableTime, 2)+std(spatialAvg_reliableTime, [], 2), 'b')
plot(reliableTime, mean(spatialAvg_reliableTime, 2)-std(spatialAvg_reliableTime, [], 2), 'b')
xlim([100,550]);
ylim([-0.5,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Avg Reliability Over Electrodes at Time Points >100 ms (+- SD)')
hold off

% 72-Class
% Plot the reliability across time, with standard deviation across random
% permutations
figure(1);
subplot(2,2,3);

plot(t, mean(avg_space_reliability_time_72Class, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(t, mean(avg_space_reliability_time_72Class, 2)+std(avg_space_reliability_time_72Class, [], 2), 'b')
plot(t, mean(avg_space_reliability_time_72Class, 2)-std(avg_space_reliability_time_72Class, [], 2), 'b')
xlim([-150,550]);
ylim([-0.5,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Avg Reliability Over Electrodes Shown Across Time (+- SD)')
annotation ('textbox', [0.45, 0.5, 0.1, 0.1], ...
    'String', {
        'In this case, grouping 72 stimuli into 6 categories reduces reliability. These data seem particularly reliable ~120 ms - 300 ms'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

text(1, 1.15, '72-Class', 'Units', 'normalized', 'FontSize', 20, 'FontWeight', 'bold');

hold on;

% Most reliable time points
reliableTimePoints = 16:40;
reliableTime = t(:,reliableTimePoints);
spatialAvg_reliableTime = avg_space_reliability_time_72Class(reliableTimePoints,:);

subplot(2,2,4);
plot(reliableTime, mean(spatialAvg_reliableTime, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(reliableTime, mean(spatialAvg_reliableTime, 2)+std(spatialAvg_reliableTime, [], 2), 'b')
plot(reliableTime, mean(spatialAvg_reliableTime, 2)-std(spatialAvg_reliableTime, [], 2), 'b')
xlim([100,550]);
ylim([-0.5,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Avg Reliability Over Electrodes at Time Points >100 ms (+- SD)')
hold off

%% Plot 6-Class Category ERPs

[xAvg, yAvg] = Preprocessing.averageTrials(X, labels6, 20);

figure();
set(gcf, 'Position', [300,300,1200,950]);

for i = 1:6
    
    % Initiate the current subplot
    subplot(2, 3, i)
    
    % Subset out the data for the current stim category
    % time x trials
    temp = squeeze(xAvg(96, :, yAvg==i));
    
    % Plot 30 averaged pseudo-trials from each category
    % X-values are our pre-loaded time vector in msec
    % Y-values are the single trials (matlab will automatically plot all
    %       columns if given a matrix to plot)
    % Color by category
    % Thinner linewidth here since we have a lot of single trials
    plot(t, temp(:, 1:30), 'color', rgb6{i},...
        'linewidth', 1);
    hold on;
    
    % Plot current mean and color by category
    % We take the mean across the 2nd (trial) dimension
    % Color the mean black and use a larger linewidth
    plot(t, mean(temp,2), 'k',...
        'linewidth', 2);
    
    % Our aesthetics from before
    grid on
    xlabel('Time (msec)'); ylabel('Voltage (\muV)')
    ylim([-40 40])
    xlim([-112 512])
    set(gca, 'fontsize', 16)
    
    % Get current axis limits
    xLimits = xlim;
    yLimits = ylim;
    
    % Show stimulus images as background
    hImg = imagesc(xLimits, yLimits, flipud(stimImages{i}));
    set(hImg, 'AlphaData', 0.3);
    uistack(hImg, 'bottom');
    set(gca, 'Layer', 'top');
    axis normal;
    
    % We can programmatically include the category number in the title
    title([catLabelsElaborate{i}])
    
end

% Group Title
sgtitle('6-Class, Electrode 96, 30 Trial ERP', 'FontSize', 20, 'FontWeight', 'bold');

% Annotation
annotation ('textbox', [0.47, 0.45, 0.1, 0.1], ...
    'String', {
        'The ERP, across categories, larely spans 100 ms - 300 ms time window, likely driving the reliability at those timepoints'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

%% Time-Resolved Classifcation Accuracy Bin Size Selection
% Here we'll explore sliding-window classsification with varying bin size
% and a step size of 1, to find the max classification accuracy that can be
% achieved across all electrodes, for our 6-class EEG dataset

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 15);  % Average Data

% Define bin sizes from 1 to 40 with step size 1
binSizes = 1:40;
stepSize = 1;  % Sliding step (can adjust for smoother results)
numBinsTested = length(binSizes);
maxAccuracies = zeros(numBinsTested, 1); % Store max accuracy for each bin size

numTimePoints = size(xAvg, 2); % Time is now the second dimension

allAccuracies = cell(numBinsTested, 1);

% Loop through each bin size
for i = 1:numBinsTested
    timeBinSize = binSizes(i);
    numBins = floor((numTimePoints - timeBinSize) / stepSize) + 1; % Compute bins
    
    accuracies = zeros(numBins, 1);
    
    % Sliding window classification for this bin size
    for b = 1:numBins
        timeStart = (b - 1) * stepSize + 1;
        timeEnd = timeStart + timeBinSize - 1;
        
        if timeEnd > numTimePoints
            break; % Avoid exceeding time points
        end

        X_bin = xAvg(:, timeStart:timeEnd, :); % Extract trials for current window
        
        M = Classification.crossValidateMulti(X_bin, yAvg, 'rngType', rnd_seed); % Run classifier
        accuracies(b) = M.accuracy; % Store accuracy
    end
    
    % Store the max accuracy for this bin size
    allAccuracies{i} = accuracies;
    maxAccuracies(i) = max(accuracies);
end

% Plot max classification accuracy vs bin size
figure;
plot(binSizes, maxAccuracies, '-o', 'LineWidth', 2); % Convert samples to ms
xlabel('Time Bin Size (ms)');
ylabel('Max Classification Accuracy');
title('Effect of Bin Size on Max Accuracy');
ylim([0, 1]); % Accuracy range
grid on;

%% Plot Time-Resolved Classification at Selected Bin Size

figure;
set(gcf, 'Position', [300,300,900,800]);

subplot(2,1,1);

plot(t(timeAxis), allAccuracies{6}, '-o', 'LineWidth', 2);
xlabel('Centered Window Time (ms)');
ylabel('Classification Accuracy');
title(sprintf('Sliding Window Classification (Window = 6, Step = %d)', stepSize));
ylim([0, 1]); % Accuracy range
grid on;

xline(128,'--', 'color', 'r', 'LineWidth', 2);
xline(200,'--', 'color', 'r', 'LineWidth', 2);


subplot(2,1,2);
grid on;

for i = 1:6
    
    temp = squeeze(xAvg(96, :, yAvg==i));
     
    plot(t, mean(temp,2), 'color', rgb6{i},...
        'linewidth', 2);
    title('Avg ERP for Each Category Label (6-Class)');
    
    xlim([-100, 500]);
    grid on;
    hold on
end

xline(128,'--', 'color', 'r', 'LineWidth', 2);
xline(200,'--', 'color', 'r', 'LineWidth', 2);

% Annotation
annotation ('textbox', [0.47, 0.45, 0.1, 0.1], ...
    'String', {
        'Classification accuracy across 6 classes, seems to be driven by negative peak 1 (N1)'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

hold off

legend(catLabels);
%% Classify 6-Class 3D dataset at Selected Time-Window

% In summary so far, we've identified that in this case, time-resolved
% reliability averaged over electrodes, served as a decent proxy for
% identifying a time window for best classificaiton. In this case the time
% window of both the highest reliability and the highest classificaiton
% accuracy is ~130 ms - 200 ms. This seems to indicate that for the
% present experiment, the classification is driven by the first negative
% peak of the ERP across the 6 classes.

% Now lets classify the 6-class dataset, using the best time window, and
% visualize the results.
startT = find(t==128);
endT = find(t==208);


% Classificaton across all data
MAll = Classification.crossValidateMulti(xAvg, yAvg, 'rngType', rnd_seed); % Run classifier

% Classification at selected best timepoints
MBest = Classification.crossValidateMulti(xAvg(:, startT:endT,:), yAvg, 'rngType', rnd_seed); % Run classifier

% Visualize Classificaiton Results

% Plot Confusion Matrices
figure;
sgtitle('Classification Confusion Matrices: Select Timepoints vs. All Timepoints');
set(gcf, 'Position', [100,500,1250,450]);
subplot(1,2,1);

CMAll = MAll.CM;
Visualization.plotMatrix(CMAll, 'colorbar', 1, 'matrixLabels', 1,...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title('All Timepoints');
set(gca, 'fontsize', 16)

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', sprintf('Accuracy:%s',MAll.accuracy),...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

hold on;

subplot(1,2,2);

CMBest = MBest.CM;
Visualization.plotMatrix(CMBest, 'colorbar', 1, 'matrixLabels', 1,...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title('Select Timepoints');
set(gca, "FontSize",16);

Annotation  = sprintf('%s %f %s %f', 'All Timepoints:', MAll.accuracy, ' Select Timepoints:', MBest.accuracy);

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        Annotation},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

%% Compute RDM
[RDMAll, paramsAll]= RDM_Computation.computeCMRDM(CMAll, ...
    'normalize', 'diagonal');
[RDMBest, paramsBest]= RDM_Computation.computeCMRDM(CMBest, ...
    'normalize', 'diagonal');

%% Plot Dendrograms
figure();
set(gcf, 'Position', [100,500,1250,550]);

sgtitle('Multiclass LDA Dendrogram: All Timepoints vs Best Timepoints');

subplot(1,2,1)


stimPath = 'UnitTests/testVisualizations/6ClassStim';

Visualization.plotDendrogram(RDMAll,'yLim', [0 1], 'nodeLabels', catLabels, 'nodeColors', rgb6, 'iconPath', stimPath);

title('All Timepoints');
set(gca, 'fontsize', 16); 
ylabel('Distance');
hold on

subplot(1,2,2)

Visualization.plotDendrogram(RDMBest,'yLim', [0 1], 'nodeLabels', catLabels, 'nodeColors', rgb6, 'iconPath', stimPath);

title('Best Timepoints');
set(gca, 'fontsize', 16);
ylabel('Distance');
hold off
%% Plot MDS

figure()
sgtitle('Multiclass LDA MDS Plot');
set(gcf, 'Position', [200,500,1050,550]);

subplot(1,2,1)
Visualization.plotMDS(RDMAll, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('All Timepoints');
set(gca, 'fontsize', 16)

subplot(1,2,2)
Visualization.plotMDS(RDMBest, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('Best Timepoints');
set(gca, 'fontsize', 16)

