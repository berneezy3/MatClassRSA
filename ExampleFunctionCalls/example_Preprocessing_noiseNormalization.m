% noiseNormalization.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for Preprocessing.noiseNormalization() function within
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

%% 3D input

[norm_data, sigma_inv] = Preprocessing.noiseNormalization(X_3D, Y);
%% 2D input

[norm_data, sigma_inv] = Preprocessing.noiseNormalization(X_2D, Y);

