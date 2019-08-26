% testPlotDendrogram.m
% ---------------------
% Nathan - Aug 13, 2019
%
% Testing expected successful and unsuccessful calls to plotDendrogram.m.

clear all; close all; clc

rng('shuffle');

% Load pre-computed cross-validated Euclidean RDMs and average across time and across subjects
ec_rdms = load('euclidean_rdms.mat');
ec_rdms = ec_rdms.euclidean_rdms;
ec_rdms = squeeze(mean(ec_rdms, 1));
ec_rdms = squeeze(mean(ec_rdms, 3));

% Set diagonal to 0 (currently NaN)
for i=1:size(ec_rdms, 1)
    ec_rdms(i,i) = 0.0;
end

% Change as needed
iconpath = './stimuli/';

%% Plot dendrogram with no options
% Issue: changing orientation does not seem to do anything.

figure;
plotDendrogram(ec_rdms, 'fontsize', 10, 'orientation', 'right');

%% Plot dendrogram with iconPath
% Looks good. Need to check icon ordering!

figure;
plotDendrogram(ec_rdms, 'iconPath', iconpath, 'iconSize', 15);

%% Plot dendrogram with nodeColors
% Looks good I think? Need to check ordering.

figure;
nodeColors = cell(1,72);
colors = {'y', 'm', 'c', 'r', 'b'};
for i=1:72
    nodeColors{i} = colors{randi(length(colors))};
end
plotDendrogram(ec_rdms, 'nodeColors', nodeColors);

%% Plot dendrogram with nodeLabels
% Error message (probably a Matlab version or something):
% Undefined function or variable 'xticklabels'.
% Error in plotDendrogram (line 138)
%        xticklabels(ip.Results.nodeLabels);

figure;
nodelabels = cell(1,72);
labels = {'cat', 'dog', 'fish', 'rabbit', 'turtle', 'snail'};
for i=1:72
    nodelabels{i} = labels{randi(length(labels))};
end
plotDendrogram(ec_rdms, 'nodeLabels', nodelabels, 'fontSize', 8);
set(gca,'xTickLabelRotation', 45);




