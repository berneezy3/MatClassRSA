% testPlotMST.m
% ---------------------
% Nathan - Aug 13, 2019
%
% Testing expected successful and unsuccessful calls to plotMST.m.

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
iconpath = '/Users/babylab/NKong/MatClassRSA/MatClassRSA/UnitTests/stimuli/';

%% Plot MST with no options
% Looks good

figure;
plotMST(ec_rdms);

%% Plot MST with iconPath
% Looks good. Need to check icon ordering!

figure;
plotMST(ec_rdms, 'iconPath', iconpath);

%% Plot MST with nodeColors
% This breaks.

figure;
colors = cell(1,72);
for i=1:72
    colors{i} = 'm';
end
plotMST(ec_rdms, 'nodeColors', colors);

%% Plot MST with nodeLabels
% This breaks. Maybe due to the nodelabels but not sure.

figure;
nodelabels = cell(1,72);
labels = {'cat', 'dog', 'fish', 'rabbit', 'turtle', 'snail'};
for i=1:72
    nodelabels{i} = labels{randi(length(labels))};
end
plotMST(ec_rdms, 'nodeLabels', nodelabels);








