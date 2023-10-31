% example_v2_largeClassNumber.m
% -----------------------------------
% Example code for visualization of multidimensional scaling
% plotMDS.m
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed, and colored labels 
%  - Loading 3D dataset
%  - Instantiating MatClassRSA object
%  - Proprocess Data	
%  - Classify Data
%  - Visualize confusion matrix and multidimensional scaling

%Ray - October, 2023


% Clear workspace
clear all; close all; clc

% Define function parameters and random number generator seed, and colored
% category labeles
timepoint_idx = 17:22; % 144:224 ms
n_trials_to_avg = 15;
rnd_seed = 5;
rgb6 = {[0.1216    0.4667    0.7059],  ...  % Blue
    [1.0000    0.4980    0.0549] ,     ...  % Orange
    [0.1725    0.6275    0.1725] ,     ...  % Green
    [0.8392    0.1529    0.1569]  ,    ...  % Red
    [0.5804    0.4039    0.7412]  ,    ...  % Purple
    [0.7373    0.7412    0.1333]};          % Chartreuse
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'}; % category labels

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat');

% Make MatClassRSA object
RSA = MatClassRSA;

% Data preprocessing (noise normalization, shuffling, pseudo-averaging),
% where the random seed is set to rnd_seed
[X_shuf, Y_shuf,rndIdx] = RSA.Preprocessing.shuffleData(X, labels72,'rngType', rnd_seed);
[X_shufNorm, sigma_inv] = RSA.Preprocessing.noiseNormalization(X_shuf, Y_shuf);
[X_shufNormAvg, Y_shufAvg] = RSA.Preprocessing.averageTrials(X_shufNorm, Y_shuf, n_trials_to_avg, 'rngType', rnd_seed);

%Classify data with LDA with PCA
M = RSA.Classification.crossValidateMulti(X_shufNormAvg, Y_shufAvg, 'PCA', .99, 'rngType', rnd_seed, 'timeUse', timepoint_idx);

%Visualize confusion matrix
figure(1)
RSA.Visualization.plotMatrix(M.CM, 'colorbar', 1);
title('Multiclass LDA Confusion Matrix');
set(gca, 'fontsize', 16)

%Convert CM to RDM, Visualize RDM
RDM_LDA = RSA.RDM_Computation.computeCMRDM(M.CM);

figure(2)
RSA.Visualization.plotMDS(RDM_LDA);
set(gca, 'fontsize', 16)
title('Multiclass LDA MDS');