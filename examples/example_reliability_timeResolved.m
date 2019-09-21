% example_reliability_timeResolved.m
% ---------------------
% Nathan - Sept 5, 2019
%
% Example code for compute reliability across time using
% computeSpaceTimeReliability.m.

clear all; close all; clc

rng('shuffle');
n_perm = 10;
rnd_seed = 0;

% Load data
load('S06.mat');

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed.
reliability_time = computeSpaceTimeReliability(X, labels72, n_perm, rnd_seed);

% Average reliabilities across space
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
