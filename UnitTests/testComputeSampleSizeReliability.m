% testComputeSampleSizeReliability.m
% -------------------------------------------
% Blair - Sep 02, 2019

clear all; close all; clc
load('/user/b/blairbo/Codebase/MatClassRSA/UnitTests/S06.mat')

X2d = squeeze(X(96,:,:))';

%% 3D input
r = computeSampleSizeReliability(X, labels72, 19, 1000);