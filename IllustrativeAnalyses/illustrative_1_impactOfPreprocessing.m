% illustrative_1_impactOfPreprocessing.m
% -----------------------------------------
% Illustrative example code for implementing and visualizing preprocessing steps
% on classification outputs. This helps to identify the best paramters by which
% to preprocess a dataset, using +Preprocessing, +Classification, 
% and +Visualization modules
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Defining class labels and aesthetics
%  - Loading 3D dataset
%  - Trial Averaging on Classification Accuracy
%  - Noise Normalization on Classification Accuracy
%  - Noise Normalization on Transfer Learning Accuracy
%  - Data Shuffling on Data Shape


% Ray - March, 2025

%% Setup Workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 4;

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

%% Trial Averaging on ERP Shape

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data

[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'rngType', rnd_seed, 'handleRemainder', 'append');  % Apply group averaging

% Visualize 10 single trials (before trial averaging) and 10
% pseudotrials (after trial averaging)
subplot(2,1,1)
for i=1:length(unique(yShuf))
dim3 = find(yShuf==i);    
plot(t, squeeze(X(96, :, dim3(1))), 'color', rgb6{i}, ...
    'linewidth', 1.2);
hold on
end
hold off
ylabel('\mu V'); grid on
title('Before: 10 Single Trials, Electrode 96');
set(gca, 'fontsize', 14)
xlim([-100 500])
grid off
legend(catLabelsElaborate);

subplot(2,1,2)
for j=1:length(unique(yShuf))
dim3 = find(yShuf==j);
plot(t, squeeze(xAvg(96, :, dim3(1))), 'color', rgb6{j}, ...
    'linewidth', 1.2);
hold on
end

hold off
title('After: 10 Averaged Pseudotrials, Electrode 96')
xlabel('Time (ms)');
ylabel('\mu V'); grid off
legend(catLabelsElaborate);

set(gcf, 'Position', [400,500,900,800]);
set(gca, 'fontsize', 14)


xlim([-100 500])
sgtitle('ERP Shape Before and After Trial Averaging', ...
    'FontSize', 20, ...
    'FontWeight', 'bold'); 

annotation ('textbox', [0.48, 0.46, 0.1, 0.1], ...
    'String', sprintf('Trial Averaging Strengthens ERP Shape for Classifcation'),...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

%% Group Size on Accuracy

% This may take a while to run

% Define range of group sizes to test
groupSizes = 5:80;
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
set(gca, 'fontsize', 16)
grid on;

%% Noise Normalization on Covariance and Accuracy

% Noise normalization may help to de-emphasize local covariances that may
% result from electrical noise. However, it may also dampen biologically
% relvant covariance structure that may aid within-participant
% classification. Noise normalization may be especially helpful for
% transfer leanring between participants.

% Shuffle Data
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);

% Normalize data
[X_norm, sigma_inv] = Preprocessing.noiseNormalization(xShuf, yShuf);

% Average Trials
[xAvgNorm, yAvgNorm] = Preprocessing.averageTrials(X_norm, yShuf, 10,  'rngType', rnd_seed, 'handleRemainder', 'append');
[xAvg, yAvg] = Preprocessing.averageTrials(xShuf, yShuf, 10,  'rngType', rnd_seed, 'handleRemainder', 'append');

% Electrode covariance before Normalization
reshapedX = reshape(xAvg, size(xAvg,1),[]);
cov_matrix = cov(reshapedX');

% Parameters for SVM Classification Accuracy
gamma_opt = .0032;
C_opt = 100000;

% Classify Data
M = Classification.crossValidateMulti(xAvg , yAvg, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'gamma', gamma_opt, 'C', C_opt ...
);
M.accuracy;

% Classify Normalized Data
MNorm = Classification.crossValidateMulti(xAvgNorm, yAvgNorm, ...
    'classifier', 'SVM', ...
    'PCA', 0.99, ...
    'gamma', gamma_opt, 'C', C_opt ...
);
MNorm.accuracy


figure;
set(gcf, 'Position', [100,100,1200,1200]);
subplot(2,2,1)
imagesc(cov_matrix);
title('Covariance: Before Normalization');
xlabel('Electrode Number')
ylabel('Electrode Number')
colorbar;
axis equal;
axis tight;
set(gca, 'fontSize', 14);
hold on;

subplot(2,2,2)
RDM = RDM_Computation.computeCMRDM(M.CM);
Visualization.plotMatrix(M.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Classification Accuracy Before Norm: %.2f%%', M.accuracy*100));
set(gca, 'fontSize', 14);


% Electrode covariance after Normalization
reshapedX_norm = reshape(xAvgNorm, size(xAvgNorm,1),[]);
cov_matrix_norm = cov(reshapedX_norm');

subplot(2,2,3)
imagesc(cov_matrix_norm);
title('Covariance: After Normalization');
xlabel('Electrode Number');
ylabel('Electrode Number');
colorbar;
axis equal;
axis tight;
set(gca, 'fontSize', 14);
hold off;

subplot(2,2,4)
RDMNorm = RDM_Computation.computeCMRDM(MNorm.CM);
Visualization.plotMatrix(MNorm.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6)
title(sprintf('Classification Accuracy After Norm: %.2f%%', MNorm.accuracy*100));
set(gca, 'fontSize', 14);

sgtitle('Noise Normalization on Electrode Covariance and Classification Results', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

annotation ('textbox', [0.38, 0.4, 0.2, 0.2], ...
    'String', sprintf('While noise normalization may help to de-emphasize unwanted local covariance resulting from electrical noise, It may also perturb biologically relevant covariance structure... which may impact classification accuracy'),...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


%% Noise Normalization Important for Transfer Learning

% load 3D training participant data
trainParticipant = load('S01.mat');

% load 3D test participant data
testParticipant1 = load('S04.mat');
testParticipant2 = load('S05.mat');
testParticipant3 = load('S08.mat');


% --------- Train on Participant 1, without Noise Normalization -----------

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rnd_seed);  % Shuffle Data
[xAvg, yAvg] = Preprocessing.averageTrials(xShuf, yShuf, 30, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

% SVM classificaiton
M = Classification.trainMulti_opt(xAvg, yAvg, 'PCA', 0.99, ...
   'classifier', 'SVM', 'rngType', rnd_seed);


% --------- Test on Other Paricipants, Without Noise Normalization --------

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant1.X, testParticipant1.labels6, 'rngType', rnd_seed);  % Shuffle Data
[xAvg, yAvg] = Preprocessing.averageTrials(xShuf, yShuf, 30, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P3 = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant2.X, testParticipant2.labels6, 'rngType', rnd_seed);  % Shuffle Data
[xAvg, yAvg] = Preprocessing.averageTrials(xShuf, yShuf, 30, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P4 = Classification.predict(M, xAvg, 'actualLabels', yAvg);


% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant3.X, testParticipant3.labels6, 'rngType', rnd_seed);  % Shuffle Data
[xAvg, yAvg] = Preprocessing.averageTrials(xShuf, yShuf, 30, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P7 = Classification.predict(M, xAvg, 'actualLabels', yAvg);



% -------- Training on Participant 1, with Noise Normalization ------------

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

% SVM classificaiton
M = Classification.trainMulti_opt(xAvg, yAvg, 'PCA', 0.99, ...
   'classifier', 'SVM', 'rngType', rnd_seed);


% ----- Predicting on all other Participants, with Noise Normalization ----

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant1.X, testParticipant1.labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P3Norm = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant2.X, testParticipant2.labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P4Norm = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant3.X, testParticipant3.labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 40, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

P7Norm = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% ---------------------------- Plot --------------------------------------
figure;
set(gcf, 'Position', [150,300,1800,1100]);

subplot(2,3,1)
Visualization.plotMatrix(P3.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 1: %.2f%% Accuracy', P3.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(2,3,2)
Visualization.plotMatrix(P4.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 2: %.2f%% Accuracy', P4.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(2,3,3)
Visualization.plotMatrix(P7.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 3: %.2f%% Accuracy', P7.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(2,3,4)
Visualization.plotMatrix(P3Norm.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 1: %.2f%% Accuracy', P3Norm.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(2,3,5)
Visualization.plotMatrix(P4Norm.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 2: %.2f%% Accuracy', P4Norm.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(2,3,6)
Visualization.plotMatrix(P7Norm.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
title(sprintf('Test Participant 3: %.2f%% Accuracy', P7Norm.accuracy*100'));
set(gca, 'fontsize', 14)


sgtitle('Transfer Learning from One Participant to Others Within the Same Experiment', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

annotation ('textbox', [0.48, 0.45, 0.1, 0.1], ...
    'String', sprintf('Noise Normalization may help to standardize noise between participants, helping to reduce risk of overfitting to noise-driven covariance structure'),...
    'FontSize', 20, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

annotation ('textbox', [0.008, 0.7, 0.101, 0.101], ...
    'String', sprintf('No Noise Normalization'),...
    'FontSize', 25, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

annotation ('textbox', [0.008, 0.2, 0.101, 0.101], ...
    'String', sprintf('Normalization'),...
    'FontSize', 25, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

%% Data Shuffling on Data Shape

% load two dimensional dataset (trial X time)
load('losorelli_100sweep_epoched.mat')

% This data has been taken from: S.Losorelli, et al, Factors influencing 
% classification of frequency following responses to speech and music stimuli,
% Hearing Research,Volume 398, 2020, https://doi.org/10.1016/j.heares.2020.108101

% Run shuffleData.m with 2D EEG data, 6-class labels vector, participant vector, and random seed set to rnd_seed.
[X_shuf, Y_shuf, P_shuf, rndIdx] = Preprocessing.shuffleData(X, Y, P, 'rngType', rnd_seed);

participant1 = find(P_shuf==1);
class1 = find(Y_shuf==1);

allIndeces = intersect(participant1, class1);

% visualize shuffled trials and grand average
figure;
set(gcf, 'Position', [410,550,455,455]);
subplot(2,1,1);
sgtitle('Shuffling of Classes');
plot(Y, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'o', 'markerSize', 2);
title("Unshuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(Y_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x', 'markerSize', 1);
title("Shuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

figure;
set(gcf, 'Position', [867,550,455,455]);
subplot(2,1,1);
sgtitle('Grand Average Across All Classes');
plot(t, squeeze(mean(X_shuf(allIndeces,:),1)), 'color', 'r',...
    'linewidth', 1);
ylabel('\mu V');
xlabel('time (ms)');
grid on;
title('Before Shuffle');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(t, squeeze(mean(X_shuf(allIndeces,:),1)), 'color', 'r',...
    'linewidth', 1);
ylabel('\mu V'); 
xlabel('time (ms)');
grid on;
title('After Shuffle');
set(gca, 'fontsize', 12)

annotation ('textbox', [0.73, 0.3, 0.25, 0.25], ...
    'String', {
        'Shuffling classes does not change the grand average'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

% visualize shuffled participants and participant average
figure;
set(gcf, 'Position', [410,10,455,455]);
subplot(2,1,1);
sgtitle('Shuffling of Participants');
plot(P, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'o', 'markerSize', 2);
title("Unshuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(P_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x', 'markerSize', 1);
title("Shuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

figure;
set(gcf, 'Position', [867,10,455,455]);
subplot(2,1,1);
sgtitle('Participant Averages');
for i = 1:13
        temp = squeeze(mean(X(P==i,:),1));
        plot(t, temp);
        hold on;     
end
ylabel('\mu V'); 
grid on;
xlabel('time (ms)');
title('Before Shuffle');
set(gca, 'fontsize', 12)
legend('1','2','3','4','5','6','7','8','9','10','11','12','13');
set(gca, 'fontsize', 12)
hold on;

subplot(2,1,2);
for i = 1:13
        temp = squeeze(mean(X_shuf(P_shuf==i,:),1));
        plot(t, temp);
        hold on;     
end
ylabel('\mu V');
xlabel('time (ms)');
grid on;
title('After Shuffle');
set(gca, 'fontsize', 12)

annotation ('textbox', [0.1, 0.4, 0.25, 0.25], ...
    'String', {
        'Shuffling participants does not impact participant averages'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


