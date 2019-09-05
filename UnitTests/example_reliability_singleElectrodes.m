% example_reliability_singleElectrodes.m
% ---------------------
% Nathan - Sept 5, 2019
%
% Example code for compute reliability across space using
% computeSpaceTimeReliability.m.

% TODO: Add plot of scalp map

clear all; close all; clc

rng('shuffle');
n_perm = 10;
rnd_seed = 0;

% Load data
load('S06.mat');

% Run computeSpaceTimeReliability.m with 3D EEG data, 72 class labels
% vector, n_perm permutations and random seed set to rnd_seed.
reliability_time = computeSpaceTimeReliability(X, labels72, n_perm, rnd_seed);

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