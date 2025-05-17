% shuffleData.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for Preprocessing.shuffleData() function within
% the +PreProcessing module


clear all; close all; clc

rngSeed = 3;
nTrial = 1000;
nSpace = 10;
nTime = 20;
nCatagories = 10;
nParticipants = 3;

X_3D = rand(nSpace, nTime, nTrial);
X_2D = rand(nTrial, nTime);
P = randi(nParticipants, [1 nTrial]);
Y = randi(nCatagories, [1 nTrial]);

%% 3D input, RNG set by timestamp

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y);
%% 2D input, RNG set by timestamp

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_2D, Y);
%% Reproducible RNG, Single-Argument

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, 'rngType', {rngSeed,'philox'});
%% Participant vector

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, P);
