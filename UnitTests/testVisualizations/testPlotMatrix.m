% testPlotMatrix.m
% ---------------------
% Nathan - Aug 12, 2019
%
% Testing expected successful and unsuccessful calls to plotMatrix.m.

clear all; close all; clc

rng('shuffle');

% Load pre-computed cross-validated Euclidean RDMs and average across time and across subjects
ec_rdms = load('euclidean_rdms.mat');
ec_rdms = ec_rdms.euclidean_rdms;
ec_rdms = squeeze(mean(ec_rdms, 1));
ec_rdms = squeeze(mean(ec_rdms, 3));

% Change as needed
iconpath = './stimuli/';

RSA = MatClassRSA;

%% Plot RDM with basic options -- font and colormap
% Looks good

RSA.Visualization.plotMatrix(ec_rdms, 'colormap', 'jet', 'FontSize', 5, 'textRotation', 45, 'matrixLabels', 0, 'matrixLabelColor', 'white');

%% Plot RDM without any entry labels and colour bar
% Looks good

RSA.Visualization.plotMatrix(ec_rdms, 'colormap', 'jet', 'matrixLabels', 0, 'colorbar', 1);

%% Plot RDM with icons
% Looks good. Need to check icon ordering!

RSA.Visualization.plotMatrix(ec_rdms, 'colormap', 'jet', 'matrixLabels', 0, 'iconPath', iconpath, 'iconSize', 8);

%% 

RSA.Visualization.plotMatrix(ec_rdms, 'colormap', 'jet', 'matrixLabels', 0, 'iconPath', iconpath, 'iconSize', 15, 'textRotation', 45);

%% Plot RDM with custom axis labels
% Unexpected behaviour. I provide 72 labels, but the xticklabels do not
% line up with given labels. Only first 7 are displayed.

% Generate some random labels
symbols = ['a':'z' 'A':'Z', '0':'9'];
randomLabels = cell(1,72);
for i=1:72
    randString = symbols(ceil(rand(1,3)*length(symbols)));
    randomLabels{i} = randString;
end

[img] = RSA.Visualization.plotMatrix(ec_rdms, 'colormap', 'jet', 'matrixLabels', 0, 'axisLabels', randomLabels, 'FontSize', 10, 'textRotation', 45);






