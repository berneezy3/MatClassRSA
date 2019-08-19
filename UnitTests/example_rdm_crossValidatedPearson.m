% example_rdm_crossValidatedPearson.m
% ---------------------
% Nathan - Aug 19, 2019
%
% Example code for compute an RDM using the cross-validated Pearson
% correlation using computePearsonRDM.m.

clear all; close all; clc

rng('shuffle');
n_perm = 3;

% Load data
load('S06.mat');
n_time = size(X, 2);
n_label72 = max(unique(labels72));
n_label6 = max(unique(labels6));

%% Compute 72 class RDMs without random seed and without noise normalization
fprintf('Compute 72 class RDMs without random seed and without noise normalization.\n')
time_resolved_rdms = zeros(n_time, n_label72, n_label72, n_perm);

% Loop through time to compute an RDM at each time point
for i=1:n_time
    fprintf('Time point %d\n', i);
    data = squeeze(X(:,i,:));
    rdms = computePearsonRDM(data, labels72, n_perm);
    time_resolved_rdms(i,:,:,:) = rdms;
end

% Average time-resolved RDMs across time and permutations
avg_rdm = squeeze(mean(time_resolved_rdms, 4));
avg_rdm = squeeze(mean(avg_rdm, 1));

% Plot the time-averaged RDM
figure;
plotMatrix(avg_rdm, 'matrixLabels', 0, 'colorMap', 'jet')

%% Compute 72 class RDMs without random seed and with noise normalization
fprintf('Compute 72 class RDMs without random seed and with noise normalization.\n')
time_resolved_rdms = zeros(n_time, n_label72, n_label72, n_perm);

% Noise normalize the data
fprintf('Performing noise normalization...\n');
[noise_norm_x, ~] = noiseNormalization(X, labels72);

% Loop through time to compute an RDM at each time point
for i=1:n_time
    fprintf('Time point %d\n', i);
    data = squeeze(noise_norm_x(:,i,:));
    rdms = computePearsonRDM(data, labels72, n_perm);
    time_resolved_rdms(i,:,:,:) = rdms;
end

% Average time-resolved RDMs across time and permutations
avg_rdm = squeeze(mean(time_resolved_rdms, 4));
avg_rdm = squeeze(mean(avg_rdm, 1));

% Plot the time-averaged RDM
figure;
plotMatrix(avg_rdm, 'matrixLabels', 0, 'colorMap', 'jet')

%% Compute 6 class RDMs without random seed and without noise normalization
fprintf('Compute 6 class RDMs without random seed and without noise normalization.\n');
time_resolved_rdms = zeros(n_time, n_label6, n_label6, n_perm);

% Loop through time to compute an RDM at each time point
for i=1:n_time
    fprintf('Time point %d\n', i);
    data = squeeze(X(:,i,:));
    rdms = computePearsonRDM(data, labels6, n_perm);
    time_resolved_rdms(i,:,:,:) = rdms;
end

% Average time-resolved RDMs across time and permutations
avg_rdm = squeeze(mean(time_resolved_rdms, 4));
avg_rdm = squeeze(mean(avg_rdm, 1));

% Plot the time-averaged RDM
figure;
plotMatrix(avg_rdm, 'matrixLabels', 0, 'colorMap', 'jet')

%% Compute 6 class RDMs without random seed and with noise normalization
fprintf('Compute 6 class RDMs without random seed and with noise normalization.\n');
time_resolved_rdms = zeros(n_time, n_label6, n_label6, n_perm);

% Noise normalize the data
fprintf('Performing noise normalization...\n');
[noise_norm_x, ~] = noiseNormalization(X, labels6);

% Loop through time to compute an RDM at each time point
for i=1:n_time
    fprintf('Time point %d\n', i);
    data = squeeze(noise_norm_x(:,i,:));
    rdms = computePearsonRDM(data, labels6, n_perm);
    time_resolved_rdms(i,:,:,:) = rdms;
end

% Average time-resolved RDMs across time and permutations
avg_rdm = squeeze(mean(time_resolved_rdms, 4));
avg_rdm = squeeze(mean(avg_rdm, 1));

% Plot the time-averaged RDM
figure;
plotMatrix(avg_rdm, 'matrixLabels', 0, 'colorMap', 'jet')




