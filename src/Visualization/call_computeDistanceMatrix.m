% call_computeDistanceMatrix.m
% ----------------------------
% Blair - March 11, 2017
%
% Calling computeDistanceMatrix as was done in the PLOS paper.
% Note: Uses the cm6 and (coming soon) cm72 from Trello.
% PLOS: Diagonal, geometric, linear

clear all; close all; clc

%%%%%%% Edit %%%%%%%
scriptDir = '/Users/Blair/Dropbox/Matlab/EEGClass dev';
cmDir = '/Users/Blair/Dropbox/Research/Experiments/Im Cl 1.2 2013/Structs/Exported for Matlab dev 2017';
fnIn = 'cm6.mat';
%%%%%%%%%%%%%%%%%%%%

addpath(genpath(scriptDir));

cd(cmDir)
cm0 = load(fnIn);
fn = fieldnames(cm0); % cell array of field names
cm = cm0.(fn{1}) % take first field of struct a

% Compute the distance matrix
dm = computeDistanceMatrix(cm, 'normalize', 'diagonal',... 
    'symmetrize', 'geometric', 'distance', 'linear')


