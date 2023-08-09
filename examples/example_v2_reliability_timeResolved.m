% example_reliability_timeResolved.m
% ----------------------------------
% Example code for computing reliability across time using
% computeSpaceTimeReliability.m
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Loading 3D dataset
%  - Instantiating MatClassRSA object
%  - Computing reliability across space	
%  - Averaging reliability over space
%  - Visualizing reliability across time with permutation standard deviation

% Nathan- Sept 5, 2019, Edited by Ray- Feb, 2022
% Edited by Ray - August, 2023

% Clear workspace
clear all; close all; clc

% Define number of permutation (n_perm) and random number generator seed
% (rnd_seed)
n_perm = 10;
rnd_seed = 5;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed
reliability_time = RSA.Reliability.computeSpaceTimeReliability(X, labels72, 'numPermutations', n_perm, 'rngType', rnd_seed);


% Average reliabilities over space
avg_space_reliability_time = squeeze(mean(reliability_time, 1));

% Plot the reliability across time, with standard deviation across random
% permutations
close
plot(t, mean(avg_space_reliability_time, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(t, mean(avg_space_reliability_time, 2)+std(avg_space_reliability_time, [], 2), 'b')
plot(t, mean(avg_space_reliability_time, 2)-std(avg_space_reliability_time, [], 2), 'b')
xlim([-150,550]);
xlabel('Time (ms)');
ylabel('Reliability');
title('Average Reliability Over Space Shown Across Time (+- SD)')