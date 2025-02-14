% example_v2_preprocessing_averageTrials.m
% --------------------------------------
% Example code for shuffling trials using
% averageTrials.m
%
% This script covers the following steps:
%   - Clearing workspace
%   - Loading 3D dataset
%   - Normalizing data
%   - Visualizing inverse square root of the covariance matrix

% Ray - April, 2022

% Clear console, figures, and workspace
clear all; close all; clc

% Load three dimensional dataset (electrode X time X trial)
load('S01.mat')

% Normalize data
[X_norm, sigma_inv] = Preprocessing.noiseNormalization(X, labels6);

% Electrode covariance before Normalization
reshapedX = reshape(X, size(X,1),[]);
cov_matrix = cov(reshapedX');

figure;
set(gcf, 'Position', [100,100,1200,600]);
subplot(1,2,1)
imagesc(cov_matrix);
title('Original Data: Electrode Covariance');
xlabel('Electrode Number')
ylabel('Electrode Number')
colorbar;
axis equal;
axis tight;
set(gca, 'fontSize', 14);
hold on;

% Electrode covariance after Normalization
reshapedX_norm = reshape(X_norm, size(X_norm,1),[]);
cov_matrix_norm = cov(reshapedX_norm');

subplot(1,2,2)
imagesc(cov_matrix_norm);
title('Electrode Covariance after Normalization');
xlabel('Electrode Number');
ylabel('Electrode Number');
colorbar;
axis equal;
axis tight;
set(gca, 'fontSize', 14);
hold off;

% Visualize inverse square root of the covariance matrix.
figure;
imagesc(sigma_inv);
colorbar;
title('Inverse Square Root of Covariance Matrix');
xlabel('Electrode Number')
ylabel('Electrode Number')
set(gca, 'fontSize', 12);











