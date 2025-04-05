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

%% Loop through time bins -- N1 is driving the classification

% Define parameters
timeBinSize = 1;
numTimePoints = size(X, 2); % Get total number of time points
numBins = floor(numTimePoints / timeBinSize); % Determine number of bins
accuraciesTime = zeros(numBins, 1);

% Shuffle Data
% Normalize noise
    xNorm = Preprocessing.noiseNormalization(Xbin,labels6);
% Avg

    

% Loop through time bins
for bin = 1:numBins
    timeStart = (bin - 1) * timeBinSize + 1;
    timeEnd = bin * timeBinSize;
    
    Xbin = X(:, timeStart:timeEnd, :);
    
    % Normalize noise
    xNorm = Preprocessing.noiseNormalization(Xbin,labels6);
    
    % Classify
    M = Classification.crossValidateMulti(Xbin, labels6);
    accuraciesTime(bin) = M.accuracy;
end

%% Plot classification accuracy across time bins
figure;
timeAxis = (1:numBins) * timeBinSize; % Time axis in sample indices
time = t(:,timeAxis);
plot(time, accuraciesTime, '-o', 'LineWidth', 2);
xlabel('Time (samples)');
ylabel('Classification Accuracy');
title('Classification Accuracy Across Time Bins');
ylim([0, 1]); % Accuracy range
grid on;
%% Increasing time bin size

% Define parameters
timeBinSize = 10;
numTimePoints = size(X, 2); % Get total number of time points
numBins = floor(numTimePoints / timeBinSize); % Determine number of bins
accuraciesTime = zeros(numBins, 1);

% Loop through time bins
for bin = 1:numBins
    timeStart = (bin - 1) * timeBinSize + 1;
    timeEnd = bin * timeBinSize;
    
    Xbin = X(:, timeStart:timeEnd, :);
    
    % Normalize noise
    xNorm = Preprocessing.noiseNormalization(Xbin,labels6);
    
    % Classify
    M = Classification.crossValidateMulti(Xbin, labels6);
    accuraciesTime(bin) = M.accuracy;
end

%% Plot classification accuracy across time bins
figure;
timeAxis = (1:numBins) * timeBinSize; % Time axis in sample indices
time = t(:,timeAxis);
plot(time, accuraciesTime, '-o', 'LineWidth', 2);
xlabel('Time (samples)');
ylabel('Classification Accuracy');
title('Classification Accuracy Across Time Bins');
ylim([0, 1]); % Accuracy range
grid on;

%% Sliding time-window classificaiton

% Parameters
timeBinSize = 5;   % Size of the moving window (samples)
stepSize = 1;       % Step size (smaller = smoother accuracy curve)
numTimePoints = size(X, 2);
numBins = floor((numTimePoints - timeBinSize) / stepSize) + 1; % Number of windows

accuracies = zeros(numBins, 1);
timeAxis = zeros(numBins, 1);

% Shuffle Data
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);

% Normalize Data
xNorm = Preprocessing.noiseNormalization(xShuf,yShuf);

% Average Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 15);

% Sliding window classification
for b = 1:numBins
    timeStart = (b - 1) * stepSize + 1;
    timeEnd = timeStart + timeBinSize - 1;

    Xbin = xAvg(:, timeStart:timeEnd, :); % Extract trials for current window
    M = Classification.crossValidateMulti(Xbin, yAvg); % Run classifier
    accuracies(b) = M.accuracy; % Store accuracy

    timeAxis(b) = mean([timeStart, timeEnd]); % Center of the time window
end
%%
% Convert sample indices to time (ms) if needed
Fs = 1000; % Example: 1000 Hz sampling rate
timeAxis_ms = (timeAxis / Fs) * 1000;

% Plot classification accuracy over time
figure;
plot(t(timeAxis), accuracies, '-o', 'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Classification Accuracy');
title(sprintf('Sliding Window Classification (Window = %d samples, Step = %d)', timeBinSize, stepSize));
ylim([0, 1]); % Accuracy range
grid on;

%% bin size
% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 15);  % Average Data

% Define bin sizes from 1 to 40 with step size 1
binSizes = 1:40;
stepSize = 1;  % Sliding step (can adjust for smoother results)
numBinsTested = length(binSizes);
maxAccuracies = zeros(numBinsTested, 1); % Store max accuracy for each bin size

Fs = 1000; % Sampling rate (Hz), adjust if needed
numTimePoints = size(xAvg, 2); % Time is now the second dimension

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
        
        M = Classification.crossValidateMulti(X_bin, yAvg); % Run classifier
        accuracies(b) = M.accuracy; % Store accuracy
    end
    
    % Store the max accuracy for this bin size
    maxAccuracies(i) = max(accuracies);
end
%% plot
% Plot max accuracy as a function of bin size
figure;
plot(binSizes, maxAccuracies, '-o', 'LineWidth', 2); % Convert samples to ms
xlabel('Time Bin Size (ms)');
ylabel('Max Classification Accuracy');
title('Effect of Bin Size on Max Accuracy');
ylim([0, 1]); % Accuracy range
grid on;

%% Find bin size with max accuracy then plot the sliding window

[maxAcc, maxIdx] = max(maxAccuracies);  % maxIdx gives the index of the max value

% Parameters
timeBinSize = maxIdx;   % Size of the moving window (samples)
stepSize = 1;       % Step size (smaller = smoother accuracy curve)
numTimePoints = size(X, 2);
numBins = floor((numTimePoints - timeBinSize) / stepSize) + 1; % Number of windows

accuracies = zeros(numBins, 1);
timeAxis = zeros(numBins, 1);

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 15);  % Average Data


% Sliding window classification
for b = 1:numBins
    timeStart = (b - 1) * stepSize + 1;
    timeEnd = timeStart + timeBinSize - 1;

    Xbin = xAvg(:, timeStart:timeEnd, :); % Extract trials for current window
    M = Classification.crossValidateMulti(Xbin, yAvg); % Run classifier
    accuracies(b) = M.accuracy; % Store accuracy

    timeAxis(b) = mean([timeStart, timeEnd]); % Center of the time window
end
%%
% Plot classification accuracy over time
figure;
plot(t(timeAxis), accuracies, '-o', 'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Classification Accuracy');
title(sprintf('Sliding Window Classification (Window = %d, Step = %d)', timeBinSize, stepSize));
ylim([0, 1]); % Accuracy range
grid on;

%% Classify
bestTimeWindow = 19-3:19+3;
bestElectrode = 96;

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 15);  % Average Data

M = Classification.crossValidateMulti(xAvg(bestElectrode, bestTimeWindow,:),yAvg);
M.accuracy

%% Test group size on accuracy

% Define range of group sizes to test
groupSizes = 50:1000;
numGroupSizes = length(groupSizes);
maxAccuracies = zeros(numGroupSizes, 1); % Store max accuracy for each group size

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
    
% Loop through different group sizes
for g = 1:numGroupSizes
    
    groupSize = groupSizes(g);
    
    try
        [xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, groupSize, 'handleRemainder', 'append');  % Apply group averaging

        % Perform classification after preprocessing
        M = Classification.crossValidateMulti(xAvg(96,19-2:19+8,:), yAvg);  % Run classifier on averaged data

        % Store the accuracy for this group size
        maxAccuracies(g) = M.accuracy;
    catch
        % Store the accuracy for this group size
        maxAccuracies(g) = 0;
    end
end

% Plot max accuracy as a function of group size
figure;
plot(groupSizes, maxAccuracies, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
%%
% Define range of group sizes to test
groupSizes = 1:50;
numGroupSizes = length(groupSizes);
maxAccuracies = zeros(numGroupSizes, 1); % Store max accuracy for each group size

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
    
% Loop through different group sizes
for g = 1:numGroupSizes
    
    groupSize = groupSizes(g);
    
    try
        [xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, groupSize, 'handleRemainder', 'append');  % Apply group averaging

        % Perform classification after preprocessing
        M = Classification.crossValidateMulti(xAvg(96,19-2:19+8,:), yAvg);  % Run classifier on averaged data

        % Store the accuracy for this group size
        maxAccuracies(g) = M.accuracy;
    catch
        % Store the accuracy for this group size
        maxAccuracies(g) = 0;
    end
end

% Plot max accuracy as a function of group size
figure;
plot(groupSizes, maxAccuracies, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
%% interpolate over errors
tempAcc = totalAccuracies(1:75);
v = 1:75;
% Find indices of nonzero and zero elements
x = find(tempAcc ~= 0); % Indices of nonzero values
y = tempAcc(x);         % Nonzero values
xi = find(tempAcc == 0); % Indices of zero values

% Perform interpolation (linear by default)
v(xi) = interp1(x, y, xi, 'linear');
v(x) = y;
%%
% Plot max accuracy as a function of group size
figure;
plot(1:75, v, '-o', 'LineWidth', 2);
xlabel('Group Size (Trials Averaged)');
ylabel('Classification Accuracy');
set(gca, 'XScale', 'log');
title('Effect of Group Size on Classification Accuracy');
ylim([0, 1]); % Accuracy range
grid on;
