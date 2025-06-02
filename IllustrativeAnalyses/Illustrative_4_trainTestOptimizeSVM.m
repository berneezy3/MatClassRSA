% Illustrative_4_trainTestOptimizeSVm.m
% -----------------------------------------
% Illustrative example code for grid search based hyperparamter tuning for
% support vector machine (SVM) classification. This helps to identify the 
% best hyperparamters by which to classify a dataset +Preprocessing, +Classification, 
% +Utils, and +Visualization modules
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Defining class labels and aesthetics
%  - Loading 3D dataset
%  - SVM Model, Default Hyperparameter Tuning
%  - SVM vs LDA: Train and Test on Partitioned Data
%  - Refining SVM Grid Search
%  - SVM vs LDA: Custom Hyperparameter Tuning

% Ray - May, 2025

%% Setup Workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 6;

% Load three dimensional datasets (electrode x time X trial),
% from the same study
load('S06.mat');

% load 3D training participant data
trainParticipant = load('S01.mat');

% load 3D test participant data
testParticipant1 = load('S04.mat');
testParticipant2 = load('S05.mat');
testParticipant3 = load('S08.mat');

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

%% SVM Model Tuning
% All models, LDA, SVM, RF, may perform differently. SVM and RF models, in
% particular, may need to be optimized for a given dataset, to achieve the
% highest classification accuracy. Within the +Classification module,
% trainMulti_opt(), trainPairs_opt(), crossValidateMulti_opt(),
% crossValidateParis_opt(), all contain grid search functionality for
% better SVM classificaiton. This may help to tune the hyperparameters of linear and
% rbf kernels. The default values over which the grid search is conducted
% for either C (linear kernel) or Gamma (rbf and linear kernels), is set as
% logspace((-5), 5, 5) or [1.0e–5, 3.1623e–3, 1.0000e+0, 3.1623e+2, 1.0e+5];

% Lets test iterating over these default values with crossValidateMulti_opt 
% on a dataset, to see how well the default SVM classification goes

% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

% Training SVM
MSVM = Classification.crossValidateMulti_opt(xAvg, yAvg, ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 0.99);

% Plot
figure;
Visualization.plotMatrix(MSVM.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('SVM: %.2f%% Accuracy', MSVM.accuracy*100'));
set(gca, 'fontsize', 14)

% Accuracy: ~67%
% Gamma: ~316
% C: ~0.0032

%% SVM vs LDA: Train and Test on Partitioned Data

% Lets compare default LDA and SVM grid search optimized models, generated
% on the same dataset.

% ---------------------- Preprocessing Steps -------------------------
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rnd_seed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'newGroup', 'rngType', rnd_seed);  % Apply group averaging

% ----------- Partition the data for training and testing --------------

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

% Split data into train and test partitions
[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% ---------------------------- Training -------------------------------
% Training LDA
MLDA = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, ...
    'classifier', 'LDA', 'PCA', 0.99);

% Training SVM
MSVM = Classification.trainMulti_opt(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 0.99);


% ---------------------------- Testing -------------------------------
% Testing LDA
PLDA = Classification.predict(MLDA, cvDataObj.testXall{1}, 'actualLabels', ...
    cvDataObj.testYall{1});

% Testing SVM
PSVM = Classification.predict(MSVM, cvDataObj.testXall{1}, 'actualLabels', ...
    cvDataObj.testYall{1});

% ----------------------------- Plot ----------------------------------
figure;
set(gcf, 'Position', [150,300,1200,500]);
subplot(1,2,1)
Visualization.plotMatrix(PLDA.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('LDA: %.2f%% Accuracy', PLDA.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(1,2,2)
Visualization.plotMatrix(PSVM.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('SVM: %.2f%% Accuracy', PSVM.accuracy*100'));
set(gca, 'fontsize', 14)

sgtitle('SVM vs LDA: Default Classification Parameters', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

annotation ('textbox', [0.40, 0.45, 0.2, 0.15], ...
    'String', sprintf('Using defaults settings, LDA classifcation outperforms SVM for this dataset'),...
    'FontSize', 18, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


%% Refining Grid Search

% In this toolbox, the scripts trainMulti_opt(), crossValidateMulti_opt(), 
% trainPairs_opt(), and crossValidatePairs_opt() scripts. scripts will conduct a grid
% search for you, over a default range of C hyperparameter values (linear and rbf
% kernels), and Gamma hyperparameter (rbf kernel). However, you can also
% specify a range of value over which to conduct a grid search.

% Let's see how me might be able to zoom in around the current best Gamma
% and C values for RBF Kernel SVM classification

% ---- Current Best -----
% Gamma: ~316 - 
% C: ~0.0032

% Number of values to iterate over for both C and Gamma during grid search
nC     = 20;   % try 20 points for C
ngamma = 20;   % try 20 points for Gamma

% Create iterable vectors for C and Gamma
C_fine = logspace(3, 5, nC);     
gamma_fine = logspace(-1.8, -3, ngamma); 

% Classify
MSVM = Classification.crossValidateMulti_opt(xAvg, yAvg, ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 0.99, 'gammaSpace', ...
    gamma_fine, 'CSpace', C_fine);

% Average across the 10 fold cross validation results
avgGamma_Opt = mean(MSVM.gamma_opt); % Best Gamma
avgC_Opt = mean(MSVM.C_opt); % Best C

% ----------------------------- Plot ----------------------------------
figure;
Visualization.plotMatrix(MSVM.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('Improved SVM Accuracy: %.2f%% Accuracy', MSVM.accuracy*100'));
set(gca, 'fontsize', 14)



%% SVM vs LDA: After Hyperparameter Tuning

% Classify using newly fine tuned hyperparameters Gamma and C
MSVM = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, ...
    'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 0.99, 'Gamma', avgGamma_Opt, 'C', avgC_Opt);

% Predict using newly trained model
PSVM = Classification.predict(MSVM, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});


% --------------------------- plot -------------------------------
figure;
set(gcf, 'Position', [150,300,1200,500]);
subplot(1,2,1)
Visualization.plotMatrix(PLDA.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('LDA: %.2f%% Accuracy', PLDA.accuracy*100'));
set(gca, 'fontsize', 14)

subplot(1,2,2)
Visualization.plotMatrix(PSVM.CM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
                        
title(sprintf('SVM: %.2f%% Accuracy', PSVM.accuracy*100'));
set(gca, 'fontsize', 14)

sgtitle('SVM vs LDA: Fine Hyperparameter Tuning', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

annotation ('textbox', [0.40, 0.45, 0.2, 0.18], ...
    'String', sprintf('After more refined hyperparameter tuning, RBF Kernel SVM Classification outperforms LDA'),...
    'FontSize', 18, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');


