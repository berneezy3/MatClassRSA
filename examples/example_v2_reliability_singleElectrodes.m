% example_v2_reliability_singleElectrodes.m
% -----------------------------------------
% Example code for computing reliability across space using
% computeSpaceTimeReliability.m
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Loading 3D dataset
%  - Computing reliability across space
%  - Averaging reliability over time
%  - Visualizing reliability across space with permutation standard deviation
%  - Visualizing reliability across time on topographical map

% Nathan - Sept 5, 2019, Edited by Ray - Febuary, 2022

% Clear workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 3;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat')

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed.
reliability_time = Reliability.computeSpaceTimeReliability(X, labels72, 'numPermutations', n_perm, 'rngType', rnd_seed);

%% Find most reliable time points

% Average reliabilities over space
avg_space_reliability_time = squeeze(mean(reliability_time, 1));

% Plot the reliability across time, with standard deviation across random
% permutations
figure(1);
subplot(1,2,1);
set(gcf, 'Position', [200,500,1250,450]);
plot(t, mean(avg_space_reliability_time, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(t, mean(avg_space_reliability_time, 2)+std(avg_space_reliability_time, [], 2), 'b')
plot(t, mean(avg_space_reliability_time, 2)-std(avg_space_reliability_time, [], 2), 'b')
xlim([-150,550]);
ylim([-0.5,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Average Reliability Over Electrodes Shown Across Time (+- SD)')
annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        'Data is most reliable >100 ms'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');
hold on;

% Most reliable time points
reliableTimePoints = 16:40;
reliableTime = t(:,reliableTimePoints);
spatialAvg_reliableTime = avg_space_reliability_time(reliableTimePoints,:);

subplot(1,2,2);
plot(reliableTime, mean(spatialAvg_reliableTime, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(reliableTime, mean(spatialAvg_reliableTime, 2)+std(spatialAvg_reliableTime, [], 2), 'b')
plot(reliableTime, mean(spatialAvg_reliableTime, 2)-std(spatialAvg_reliableTime, [], 2), 'b')
xlim([100,550]);
ylim([-0.5,1]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Average Reliability Over Electrodes at Time Points >100 ms (+- SD)')
hold off


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
xNorm = Preprocessing.noiseNormalization(X,labels6);

% Classify by LDA on most reliable electrode
figure;
sgtitle('Reliability of Single Electrode on Classification Confusion Matrices');
set(gcf, 'Position', [100,500,1250,450]);
subplot(1,2,1);

M = Classification.crossValidateMulti(xNorm(96,:, :), labels6);
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
M = Classification.crossValidateMulti(xNorm(48,:, :), labels6);
CM = M.CM;
imagesc(CM);
xlabel('Class Category');
ylabel('Predicted Class Category');
title('Unreliable Electrode (48)');
set(gca, "FontSize",14);

annotation ('textbox', [0.48, 0.5, 0.1, 0.1], ...
    'String', {
        'Electrode 96 is particularly reliable'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


hold off








