% testPlotMST.m
% ---------------------
% Nathan - Aug 13, 2019
%
% Testing expected successful and unsuccessful calls to plotMST.m.

clear all; close all; clc

rng('shuffle');

% Load pre-computed cross-validated Euclidean RDMs and average across time and across subjects
ec_rdms = load('../euclidean_rdms.mat');
ec_rdms = ec_rdms.euclidean_rdms;
ec_rdms = squeeze(mean(ec_rdms, 1));
ec_rdms = squeeze(mean(ec_rdms, 3));

% Set diagonal to 0 (currently NaN)
for i=1:size(ec_rdms, 1)
    ec_rdms(i,i) = 0.0;
end

% Change as needed
iconpath = './stimuli/';

%Create MatClassRSA object
RSA = MatClassRSA;

%% Plot MST with no options
% Looks good

figure;
img = RSA.Visualization.plotMST(ec_rdms);

%% Plot MST with iconPath
% Issue: iconSize corresponds to the resolution, not the actual size!

figure;
RSA.Visualization.plotMST(ec_rdms, 'iconPath', iconpath, 'iconSize', 40);

%% Plot MST with nodeColors
% Looks good!

figure;
colors = cell(1,72);
for i=1:36
    colors{i} = 'm';
end
for i=37:72
    colors{i} = 'b';
end
RSA.Visualization.plotMST(ec_rdms, 'nodeColors', colors, ...
    'nodeLabelSize', 8, 'edgeLabelSize', 8);

%% Plot MST with nodeLabels
% Looks good!

figure;
nodelabels = cell(1,72);
labels = {'cat', 'dog', 'fish', 'rabbit', 'turtle', 'snail'};
for i=1:72
    nodelabels{i} = [labels{randi(length(labels))}  num2str(i)];
end
nodecolors = cell(1,size(ec_rdms,1));
for i=1:size(ec_rdms,1)
    nodecolors{i} = [.3 .7 .1];
end
RSA.Visualization.plotMST(ec_rdms, 'nodeLabels', nodelabels, ...
    'nodeColors', nodecolors, 'nodeLabelSize', 8, 'edgeLabelSize', 8);








