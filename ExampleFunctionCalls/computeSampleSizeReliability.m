% computeSampleSizeReliability.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for reliabilities() function within
% the +Reilability module

clear all; close all; clc

rngSeed = 3;

load('S01.mat');


%% 3D input, RNG set by timestamp, featureIndx: temporal sample index

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15);
%% 2D input, RNG set by timestamp, featureIndx: temporal sample index

X2D = squeeze(X(96,:,:))'; % 3D (electrode x time x trial) -> single electrode 2D (trial x time)
reliabilities = Reliability.computeSampleSizeReliability(X2D, labels72, 15);
%% Reproducible RNG, Single-Argument

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'});
%% Number of Trials Per Split-half

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'numTrialsPerHalf', 20);
%% Number of Permutations Splitting Trials for Split-Half Reliability (Not Displayed)

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'}, 'numTrialsPerHalf', 20, 'numPermutations', 20);
%% Number of Permutations Choosing Trials (Displayed)

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'}, 'numTrialsPerHalf', 20, 'numPermutations', 20, 'numTrialPermutations', 20);