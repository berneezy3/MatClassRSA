% illustrative_2_singleChannelAnalyses.m
% -----------------------------------------
% Illustrative example code for single-channel classification,
% identifing the best electrode for classificaiton, and visualization of
% results, using +Preprocessing, +Reliability, +Classification, and
% +Visualization modules
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Defining class labels and aesthetics
%  - Loading 3D dataset
%  - Computing reliability over time

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



%% Find most reliable electrode at determined reliable timepoints
close

% Average reliabilities across time
avg_space_reliability_space = squeeze(mean(reliability_time(:,reliableTimePoints,:), 2));

% Plot the reliability across space, with standard deviation across random
% permutations
figure(3);
nSpace = size(X, 1);

set(gcf, 'Position', [100,500,1250,450]);
subplot(1,2,1);
plot(1:nSpace, mean(avg_space_reliability_space, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(1:nSpace, mean(avg_space_reliability_space, 2)+std(avg_space_reliability_space, [], 2), 'b')
plot(1:nSpace, mean(avg_space_reliability_space, 2)-std(avg_space_reliability_space, [], 2), 'b')
xlim([0,nSpace+1]);
xlabel('Electrode Index');
ylabel('Reliability');
title('Average Reliability Over Time for all Electrodes (+- SD)');

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        'Electrode 96 is particularly reliable'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

hold on;

% Plot average reliability across time, on scalp topographical map
subplot(1,2,2);
cBarMin = min(mean(avg_space_reliability_space, 2));
cBarMax = max(mean(avg_space_reliability_space, 2));
plotOnEgi([mean(avg_space_reliability_space, 2); nan(4,1)], [cBarMin cBarMax], true);
title('Average Reliability Over Time Topographical Map');
ylabel(colorbar, "Reliability");

% Plotting reliability over time, for electrode 91
figure(4);
set(gcf, 'Position', [500,10,800,400]);

reliability_96 = squeeze(reliability_time(96, :, :));
plot(t, mean(reliability_96, 2), 'b', 'linewidth', 2);
xlabel('Time (ms)');
ylabel('Reliability');
title('Reliability of Electrode 96 Over Time');

%% Show reliability impact on classification accuracy
close

% Normalize noise
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);
xNorm = Preprocessing.noiseNormalization(xShuf,yShuf);
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm(96,19-3:19+3, :), yShuf, 15);

% Classify by LDA on most reliable electrode
figure;
sgtitle('Reliability of Single Electrode on Classification Confusion Matrices');
set(gcf, 'Position', [100,500,1250,450]);
subplot(1,2,1);

M = Classification.crossValidateMulti(xAvg, yAvg);
CM = M.CM;
imagesc(CM);
xlabel('Class Category');
ylabel('Predicted Class Category');
title('Reliable Electrode (96)');
set(gca, "FontSize",14);

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', sprintf('Accuracy:%s',M.accuracy),...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

hold on;

% Classify by LDA on least reliable electrode

subplot(1,2,2);
% Normalize noise
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm(48,19-3:19+3, :), yShuf, 15);

M2 = Classification.crossValidateMulti(xAvg, yAvg);
CM = M2.CM;
imagesc(CM);
xlabel('Class Category');
ylabel('Predicted Class Category');
title('Unreliable Electrode (48)');
set(gca, "FontSize",14);

Annotation  = sprintf('%s %f %s %f', 'Electrode 96:', M.accuracy, ' Electrode 48:', M2.accuracy);

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        Annotation},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


hold off


%% Loop through classifying each single electrode

nElectrodes = size(X, 1);
accuraciesTime = zeros(nElectrodes, 1);

for elec = 1:nElectrodes
    
    % Select Single 
    Xsingle = X(elec, :, :);
    
    % Normalize noise
    xNorm = Preprocessing.noiseNormalization(Xsingle,labels6);
    
    % Classify
    M = Classification.crossValidateMulti(xNorm, labels6);
    accuraciesTime(elec) = M.accuracy;
end
%% Plot classification accuracy per electrode

figure;
plot(1:numElectrodes, accuraciesTime, 'b', 'linewidth', 2);
hold on; grid on
plot(1:nSpace, mean(avg_space_reliability_space, 2), 'r', 'linewidth', 2);
plot(1:nSpace, mean(avg_space_reliability_space, 2)+std(avg_space_reliability_space, [], 2), 'r')
plot(1:nSpace, mean(avg_space_reliability_space, 2)-std(avg_space_reliability_space, [], 2), 'r')
xline(96, 'linewidth', 2, 'linestyle', '--');
hold off
legend ('Classifcation Accuracy','Reliability');

xlabel('Electrode Index');
ylabel('Classification Accuracy');
title('Single-Electrode Classification Accuracy');
ylim([0, 1]); % Accuracy between 0 and 1
xlim([0,numElectrodes+1]);
grid on;

