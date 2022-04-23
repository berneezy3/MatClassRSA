% example_reliability_varyTrialSize.m
% -----------------------------------
% Example code for compute reliability varying the number of trials using
% computeSampleSizeReliability.m
%  - Clear figures, console, and workspace
%  - Set random number generator seed and sample size reliability function parameters 
%  - Load 3D dataset
%  - Instantiate MatClassRSA object
%  - Compute reliability with varying number of trials	
%  - Average reliability over space
%  - Visualize reliability as function of varying trial subset size

% Nathan - Sept 5, 2019, Edited by Ray - Febuary, 2022

% Clear workspace
clear all; close all; clc

% Define function parameters and random number generator seed
timepoint_idx = 17; % 144 ms
n_perm = 10; % Inner loop (random split-half)
n_trial_perm = 12; % Outer loop (sampling trials)
trial_subset_size_array = 1:18;
rnd_seed = 0;

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
    trial_subset_size_array, ...
    n_perm, ...
    n_trial_perm, ...
    rnd_seed ...
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

