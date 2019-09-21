% example_dataPreparation_shuffleTrials.m
% ---------------------
% Nathan - September 2, 2019
%
% Example code to shuffle trials.


clear all; close all; clc

% Load data
load('S06.mat');
Y = labels6;
nTrial = size(X, 3);

% Assume that there are 5 participants and randomly assign each trial to a
% participant
P = randi(5, [1 nTrial]);

% Random seed
r = 5;

%% Call shuffleData on the 3D data with user-specified random seed

[x_shuffle_3d, y_shuffle_3d, p_shuffle_3d] = shuffleData(X, Y, P);

%% Call shuffleData on the 3D data with user-specified random seed

[x_shuffle_3d, y_shuffle_3d, p_shuffle_3d] = shuffleData(X, Y, P, r);

%% Call shuffleData on some 2D data

X_2D = squeeze(X(1,:,:))';
[x_shuffle_2d, y_shuffle_2d, p_shuffle_2d] = shuffleData(X_2D, Y, P);

%% Call shuffleData on some 2D data with user-specified random seed

X_2D = squeeze(X(1,:,:))';
[x_shuffle_2d, y_shuffle_2d, p_shuffle_2d] = shuffleData(X_2D, Y, P, r);