% scratch__dataScalingJan2020.m
% -----------------------------
% Blair - Jan 9, 2020
%
% Looking at how to best implement data scaling prior to SVM
% classification.

clear all; close all; clc

load S06.mat

%%

%%% By-hand partition into 5 folds %%%
% Here are the trial indices for each fold
part5 = {(1:1037)', (1038:2074)', (2075:3111)', (3112:4148)', (4149:5184)'};
allIdx = 1:5184;

