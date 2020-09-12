% testPlotMDS.m
% ---------------------
% Nathan - Aug 12, 2019
%
% Testing expected successful and unsuccessful calls to plotMDS.m.

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

iconpath = './stimuli/';

%% Plot MDS with no options
% Looks good -- we get a human face cluster

figure;
plotMDS(ec_rdms, 'dimensions', [1 2]);

%% Plot MDS with >2 dimensions (should break)
% Looks good, breaks as expected

figure;
plotMDS(ec_rdms, 'dimensions', [1 2 3]);    

%% Plot MDS with icons
% Looks good. Need to check icon ordering!

nodecolors = cell(1,size(ec_rdms,1));
for i=1:size(ec_rdms,1)
    nodecolors{i} = 'b';
end
figure;
plotMDS(ec_rdms, 'iconPath', iconpath, 'nodeColors', nodecolors);

%% Plot MDS with nodeLabels
% Looks good. Need to check label ordering!

figure;
nodelabels = cell(1,72);
labels = {'cat', 'dog', 'fish', 'rabbit', 'turtle', 'snail'};
nodecolors = cell(1,size(ec_rdms,1));
for i=1:size(ec_rdms,1)
    nodecolors{i} = 'cyan';
end
for i=1:72
    nodelabels{i} = labels{randi(length(labels))};
end
plotMDS(ec_rdms, 'nodeLabels', nodelabels, 'nodeColors', nodecolors);




