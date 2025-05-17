% example_RDM_Computation.shiftPairwiseAccuracy.m
% ---------------------
% Ray - May, 2025
%
% Example function calls for shiftPairwiseAccuracy() function within
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

M = Classification.crossValidatePairs(xAvg, yAvg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

% Moving forward with this pairwise accuracies
pairAcc = M.AM;

%% Basic Function Call with Pairwise Accuracy Matrix

RDM = RDM_Computation.shiftPairwiseAccuracyRDM(pairAcc);
RDM

%% Shift Accuracies on 1-100 scale, 'pairScale' 100

scaledAcc = pairAcc*100;

RDM = RDM_Computation.shiftPairwiseAccuracyRDM(scaledAcc, 'pairScale', 100);
RDM


