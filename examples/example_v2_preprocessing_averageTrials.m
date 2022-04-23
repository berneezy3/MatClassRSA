% example_v2_preprocessing_averageTrials.m
% --------------------------------------
% Example code for shuffling trials using
% averageTrials.m
%   - Clear workspace
%   - Set random number generator seed and number of trials to average
%   - Load 3D dataset
%   - Instantiate MatClassRSA object
%   - Average trials
%   - Visualize 10 single trials vs 10 averaged pseudotrials

% Ray - April, 2022

% Clear console, figures, and workspace
clear all; close all; clc

% Set random number generator seed
rnd_seed = 0;
n_trials_to_avg = 10;

% Load three dimensional dataset (electrode X time X trial)
load('S01.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Run shuffleData.m with 3D EEG data, 6-class labels vector, number of 
% trials averaged into pseudotrial set to n_trial_to_avg, random seed set 
% to rnd_seed.
[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(X, labels6, n_trials_to_avg, 'randomseed', rnd_seed);

% Get indices of trials and pseudotrials from category 1
stIndx = find(labels6==1);
stIndx = stIndx(1:10);
ptIndx = find(Y_avg==1);
ptIndx = ptIndx(1:10);

% Visualize 10 single trials (before trial averaging) and 10
% pseudotrials (after trial averaging)
subplot(2,1,1)
plot(t, squeeze(X(96, :, stIndx)), 'color', 'r',...
    'linewidth', 1);
ylabel('\mu V'); grid on
title('Amplitude Across Time, 10 Single Trials, Electrode 96, Category 1');
set(gca, 'fontsize', 12)
xlim([-100 500])

subplot(2,1,2)
plot(t, squeeze(X_avg(96, :, ptIndx)), 'color', 'b',...
    'linewidth', 1);
title('Amplitude Across Time, 10 Averaged Pseudotrials, Electrode 96, Category 1')
xlabel('Time (ms)');
ylabel('\mu V'); grid on
set(gca, 'fontsize', 12)
xlim([-100 500])












