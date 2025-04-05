% averageTrials.m
% ---------------------
% Ray - March, 2025
%
% Example function calls for Preprocessing.averageTrials() function within
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

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5);
%% 2D input, RNG set by timestamp

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_2D, Y, 5);
%% Reproducible RNG, Single-Argument

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, 'rngType', {rngSeed,'philox'});
%% Participant vector

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, P);
%% No Shuffle After Averaging

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, P, 'endShuffle', 0);
%% Shuffle After Averaging

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, P, 'endShuffle', 1);
%% Keep and Form New Group from Trial Remainder 

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 5, P,'handleRemainder', 'newGroup');
%% Keep and Append Trial Remainder 

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 7, P,'handleRemainder', 'append');
%% Keep and distribute Trial Remainder 

[averagedX, averagedY, averagedP, whichObs] = Preprocessing.averageTrials(X_3D, Y, 6, 'handleRemainder', 'distribute');