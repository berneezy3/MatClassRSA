% computeSpaceTimeReliability.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for reliabilities() function within
% the +Reilability module

clear all; close all; clc

rngSeed = 3;

load('S01.mat');


%% 3D input, RNG set by timestamp, featureIndx: temporal sample index

reliabilities = Reliability.computeSpaceTimeReliability(X, labels72);
%% 2D input, RNG set by timestamp, featureIndx: temporal sample index

X2D = squeeze(X(96,:,:))'; % 3D (electrode x time x trial) -> single electrode 2D (trial x time)
reliabilities = Reliability.computeSpaceTimeReliability(X2D, labels72);
%% Reproducible RNG, Single-Argument

reliabilities = Reliability.computeSpaceTimeReliability(X, labels72, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

reliabilities = Reliability.computeSpaceTimeReliability(X, labels72, 'rngType', {rngSeed,'philox'});
%% Number of Permutations Splitting Trials in Split-Half Reliability

reliabilities = Reliability.computeSpaceTimeReliability(X, labels72, 'rngType', {rngSeed,'philox'}, 'numPermutations', 40);
