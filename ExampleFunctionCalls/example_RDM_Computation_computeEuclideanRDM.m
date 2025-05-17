% computeEuclideanRDM.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for computeEuclideanRDM function within
% the +RDM_Computation module

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

singleElectrodeX = squeeze(X(96,:,:));
singleTimePointX = squeeze(X(:,11,:));

%% Single Electrode, RNG set by timestamp,

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72);
%% Single Time Point , RNG set by timestamp

D = RDM_Computation.computeEuclideanRDM(singleTimePointX, labels72);
%% Reproducible RNG, Single-Argument

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', {rngSeed,'philox'});
%% Number of Permutations

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', {rngSeed,'philox'}, 'numPermutations', 20);

