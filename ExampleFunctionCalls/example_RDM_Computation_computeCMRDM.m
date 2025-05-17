% example_RDM_Computation.computeCMRDM.m
% ---------------------
% Ray - May, 2025
%
% Example function calls for computeCMRDM() function within
% the +RDM_Computation module

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

% Preprocessing steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% SVM classifiction hyperparameters
gamma_opt = 1.0000e-5;
C_opt = 100000;

M = Classification.crossValidateMulti(xAvg, yAvg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

% Moving forward with this confusion matrix
confMatrix = M.CM;

%% Basic Function Call with Confusion Matrix

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix);
RDM

%% Normalization by 'sum'
% default normalization set to 'sum'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'sum');
RDM

%% Normalization by 'diagonal'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'diagonal');
RDM

%% No normalization

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'none');
RDM

%% Symmetrizing with 'arithmetic' mean
% default symmetrization set to 'arithmetic'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'arithmetic');
RDM

%% Symmetrizing with 'geometric' mean

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'geometric');
RDM

%% Symmetrizing with 'harmonic' mean

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'harmonic');
RDM

%% No symmetrization

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'none');
RDM

%% Linear distance transformation
% default distance transformation set to 'linear'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'linear');
RDM

%% Power distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'power', 'distpower', 2);
RDM


%% Logarithmic distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'logarithmic', 'distpower', 2);
RDM

%% No distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'none');
RDM

%% Rank distances with 'rank'
% default set to 'none'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'rank');
RDM

%% Percentile rank distances

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'percentrank');
RDM

%% No ranking of distances
% this is default
[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'none');
RDM

