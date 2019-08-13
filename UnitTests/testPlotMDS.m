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

%% Plot MDS with no options
% Looks good -- we get a human face cluster

plotMDS(ec_rdms, 'dimensions', [1 2]);

%% Plot MDS with >2 dimensions (should break)
% Looks good, breaks as expected

plotMDS(ec_rdms, 'dimensions', [1 2 3]);

%% Plot MDS with icons
% Displaying icon doesn't seem to work.

nodecolors = cell(1,size(ec_rdms,1));
for i=1:size(ec_rdms,1)
    nodecolors{i} = 'b';
end
iconpath = 'stimuli/';
plotMDS(ec_rdms, 'iconPath', iconpath, 'nodeColors', nodecolors);





