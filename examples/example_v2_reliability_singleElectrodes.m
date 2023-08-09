% example_v2_reliability_singleElectrodes.m
% -----------------------------------------
% Example code for computing reliability across space using
% computeSpaceTimeReliability.m
%
% This script covers the following steps:
%  - Clearing figures, console, and workspace
%  - Setting random number generator seed and number of permutations 
%  - Loading 3D dataset
%  - Instantiating MatClassRSA object
%  - Computing reliability across space
%  - Averaging reliability over time
%  - Visualizing reliability across space with permutation standard deviation
%  - Visualizing reliability across time on topographical map

% Nathan - Sept 5, 2019, Edited by Ray - Febuary, 2022

% Clear workspace
clear all; close all; clc

% Define number of permutations and random number generator seed
n_perm = 10;
rnd_seed = 3;

% Load three dimensional dataset (electrode x time X trial)
load('S01.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed.
reliability_time = RSA.Reliability.computeSpaceTimeReliability(X, labels72, 'numPermutations', n_perm, 'rngType', rnd_seed);

% Average reliabilities across time
avg_space_reliability_space = squeeze(mean(reliability_time, 2));

% Plot the reliability across space, with standard deviation across random
% permutations
nSpace = size(X, 1);
close
plot(1:nSpace, mean(avg_space_reliability_space, 2), 'b', 'linewidth', 2);
hold on; grid on
plot(1:nSpace, mean(avg_space_reliability_space, 2)+std(avg_space_reliability_space, [], 2), 'b')
plot(1:nSpace, mean(avg_space_reliability_space, 2)-std(avg_space_reliability_space, [], 2), 'b')
xlim([0,nSpace+1]);
xlabel('Electrode Index');
ylabel('Reliability');
title('Average Reliability Over Time Shown Across Space (+- SD)');

% Plot average reliability across time, on scalp topographical map
figure;
cBarMin = min(mean(avg_space_reliability_space, 2));
cBarMax = max(mean(avg_space_reliability_space, 2));
plotOnEgi([mean(avg_space_reliability_space, 2); nan(4,1)], [cBarMin cBarMax], true);
title('Average Reliability Over Time Topographical Map');
ylabel(colorbar, "Reliability");


