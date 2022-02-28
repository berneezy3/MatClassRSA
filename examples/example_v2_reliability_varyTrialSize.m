% example_reliability_varyTrialSize.m
% ---------------------
% Nathan - Sept 5, 2019, Edited by Ray - Febuary, 2022
%
% Example code for compute reliability varying the number of trials using
% computeSampleSizeReliability.m.

clear all; close all; clc

rng('shuffle');
timepoint_idx = 17; % 144 ms
n_perm = 10; % Inner loop (random split-half)
n_trial_perm = 12; % Outer loop (sampling trials)
trial_subset_size_array = 1:18;
rnd_seed = 0;

% Load data using dataloader. Add the following datasets to "UnitTests" folder: 
%"lsosorelli_100sweep_epoched.mat", "lsosorelli_500sweep_epoched.mat","S01.mat"
run('loadUnitTestData.m')

% Make MatClassRSA object
RSA = MatClassRSA;

% Compute reliability with varying number of trials from [2,4,...,36],
% n_trial_perm trial permutations, n_perm permutations, rnd_seed random
% seed.
reliability_trials = RSA.Reliability.computeSampleSizeReliability(S01.X, ...
    S01.labels72, ...
    timepoint_idx, ...
    trial_subset_size_array, ...
    n_perm, ...
    n_trial_perm, ...
    rnd_seed ...
);

% Average across space
avg_reliability_space = mean(reliability_trials, 3);

% Plot reliability as function of varying trial subset size
close all;
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1), 'b', 'linewidth', 2);
hold on; grid on
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1)+std(avg_reliability_space, [], 1), 'b');
plot(trial_subset_size_array .* 2, mean(avg_reliability_space, 1)-std(avg_reliability_space, [], 1), 'b');
xlabel('Number of Trials');
ylabel(sprintf('Reliability at %d ms', S01.t(timepoint_idx)));
title(sprintf('Average Reliability Across Space with Increasing Number of Trials at %d ms (+- SD)', S01.t(timepoint_idx)));

