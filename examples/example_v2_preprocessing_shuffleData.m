% example_v2_preprocessing_shuffleData.m
% --------------------------------------
% Example code for shuffling trials using
% shuffleData.m
%
% This script covers the following steps:
%   - Clearing workspace
%   - Setting random number generator type and seed
%   - Loading 2D data
%   - Instantiating MatClassRSA object
%   - Shuffling data
%   - Visualizing shuffled trials and grand average
%   - Visualizing shuffled participants and participant average

% Ray - April, 2022

% clear console, figures, and workspace
clear all; close all; clc

% set random number generator seed
rnd_seed = 0;

% load two dimensional dataset (trial X time)
load('losorelli_100sweep_epoched.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Run shuffleData.m with 2D EEG data, 6-class labels vector, participant vector, and random seed set to rnd_seed.
[X_shuf, Y_shuf, P_shuf, rndIdx] = RSA.Preprocessing.shuffleData(X, Y, P, 'randomSeed', rnd_seed);

% visualize shuffled trials and grand average

% visualize shuffled participants and participant average












