% example_reliability_varyTrialSize.m
% -----------------------------------
% Example code for compute reliability varying the number of trials using
% computeSampleSizeReliability.m
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and sample size reliability function parameters 
%  - Loading 3D dataset
%  - Instantiating MatClassRSA object
%  - Computing reliability with varying number of trials	
%  - Averaging reliability over space
%  - Visualizing reliability as function of varying trial subset size

% Nathan - Sept 5, 2019, Edited by Ray - Febuary, 2022
% Edited by Ray - August, 2023

% Clear workspace
clear all; close all; clc

% Define function parameters and random number generator seed
timepoint_idx = 17; % 144 ms
n_perm = 10; % Inner loop (random split-half)
n_trial_perm = 12; % Outer loop (sampling trials)
trial_subset_size_array = 1:18;
rnd_seed = 3;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat');

% Make MatClassRSA object
RSA = MatClassRSA;

% Compute reliability with varying number of trials from [2,4,...,36],
% n_trial_perm trial permutations, n_perm permutations, rnd_seed random
% seed.
reliability_trials = RSA.Reliability.computeSampleSizeReliability(X, ...
    labels72, ...
    timepoint_idx, ...
    'numTrialsPerHalf', trial_subset_size_array, ...
    'numPermutations', n_perm, ...
    'numTrialPermutations', n_trial_perm, ...
    'rngType', rnd_seed ...
);

% Average over space
avg_reliability_space = mean(reliability_trials, 3);

% Plot reliability as function of varying trial subset size
close all;
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1), 'b', 'linewidth', 2);
hold on; grid on
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1)+std(avg_reliability_space, [], 1), 'b');
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1)-std(avg_reliability_space, [], 1), 'b');
xlabel('Number of Trials');
ylabel(sprintf('Reliability at %d ms', t(timepoint_idx)));
title(sprintf('Average Reliability Over Space with Increasing Number of Trials at %d ms (+- SD)', t(timepoint_idx)));
