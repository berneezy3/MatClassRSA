% example_visualization_plotRDM.m
% ---------------------
% Nathan - Aug 19, 2019
%
% Example code for using plotMatrix.m.

clear all; close all; clc

rng('shuffle');
n_perm = 3;

% Load data
load('S06.mat');
n_time = size(X, 2);
n_label6 = max(unique(labels6));

%% First, let's create the 6-class RDM.

fprintf('Compute 6 class RDMs without random seed and with noise normalization.\n');
time_resolved_rdms = zeros(n_time, n_label6, n_label6, n_perm);

% Noise normalize the data
fprintf('Performing noise normalization...\n');
[noise_norm_x, ~] = noiseNormalization(X, labels6);

% Loop through time to compute an RDM at each time point
fprintf('Computing RDMs...\n');
for i=1:n_time
    data = squeeze(noise_norm_x(:,i,:));
    rdms = computeEuclideanRDM(data, labels6, n_perm);
    time_resolved_rdms(i,:,:,:) = rdms;
end

% Average time-resolved RDMs across time and permutations
avg_rdm = squeeze(mean(time_resolved_rdms, 4));
avg_rdm = squeeze(mean(avg_rdm, 1));

%% Let's plot the 6-class RDM
% Plot the time-averaged RDM with entry labels and class labels

classLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};

figure;
plotMatrix(avg_rdm, ...
    'matrixLabels', 1, ...
    'colorMap', 'jet', ...
    'axisLabels', classLabels, ...
    'colorbar', 1 ...
);





