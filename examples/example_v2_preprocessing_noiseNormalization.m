% example_v2_preprocessing_averageTrials.m
% --------------------------------------
% Example code for shuffling trials using
% averageTrials.m
%
% This script covers the following steps:
%   - Clearing workspace
%   - Loading 3D dataset
%   - Instantiating MatClassRSA object
%   - Normalizing data
%   - Visualizing inverse square root of the covariance matrix

% Ray - April, 2022

% Clear console, figures, and workspace
clear all; close all; clc

% Load three dimensional dataset (electrode X time X trial)
load('S01.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Normalize data
[X_norm, sigma_inv] = RSA.Preprocessing.noiseNormalization(X, labels6);

% Visualize inverse square root of the covariance matrix.
figure;
imagesc(sigma_inv);
colorbar;
title('Inverse Square Root of Covariance Matrix');
xlabel('Electrode Number')
ylabel('Electrode Number')
set(gca, 'fontSize', 12);











