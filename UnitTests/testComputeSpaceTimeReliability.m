% testComputeSpaceTimeReliability.m
% -------------------------------------
% Blair - 02 Sep 2019

clear all; close all; clc

% Working on CCRMA directory - S06 is in .gitignore but is in the UnitTests
% folder.

load S06.mat

%% Test with default rng
rng(2)
[r] = computeSpaceTimeReliability(X, labels72);
rng
% Ok
 
 %% Test with user-specified rng
 
 [r] = computeSpaceTimeReliability(X(:,20:25,:), labels72, [], {'shuffle', 'philox'});
 rng
 % ok
 
  %% Test with user-specified rng
 
 [r] = computeSpaceTimeReliability(X(:,20:25,:), labels72, [], {1, 'philox'});
 rng
 % ok
 
 %% Test with bad rng
 
[r] = computeSpaceTimeReliability(X(:,20:25,:), labels72, [], {'2', '1'});
% ok - there is an error

%% Test with single-input rng

[r] = computeSpaceTimeReliability(X(:,20:25,:), labels72, [], 25);
rng

%% Set number of permutations to nPerms
nPerms = 16;

[r] = computeSpaceTimeReliability(X(:,20:25,:), labels72, nPerms);
assert(isequal(size(r), [124 6 nPerms]))
disp('Success')

%% Verify that plot of reliability over time, ch 96, looks right
[r1] = computeSpaceTimeReliability(X, labels72, 100);
[r2] = computeSpaceTimeReliability(X, labels72, 25);


%% Plot the reliabilities
r1_96 = squeeze(r1(96,:,:));
r2_96 = squeeze(r2(96,:,:));

close
plot(t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(t,mean(r1_96,2)-std(r1_96,[],2), 'b')

plot(t,mean(r2_96,2), 'r', 'linewidth', 2);
plot(t,mean(r2_96,2)+std(r2_96,[],2), 'r')
plot(t,mean(r2_96,2)-std(r2_96,[],2), 'r')

% Try a less good channel (Oz 75)

r1_75 = squeeze(r1(75,:,:));
r2_75 = squeeze(r2(75,:,:));

plot(t,mean(r1_75,2), 'g', 'linewidth', 2);
hold on; grid on
plot(t,mean(r1_75,2)+std(r1_75,[],2), 'b')
plot(t,mean(r1_75,2)-std(r1_75,[],2), 'b')

plot(t,mean(r2_75,2), 'k', 'linewidth', 2);
plot(t,mean(r2_75,2)+std(r2_75,[],2), 'r')
plot(t,mean(r2_75,2)-std(r2_75,[],2), 'r')

%% Visualize reliabilities on a topoplot

t0 = find(t==0);
t80 = find(t==80);
t176 = find(t==176);

r1Mean = mean(r1,3);
close
figure(1)
plotOnEgi([r1Mean(:,t0); nan(4,1)])
set(gca, 'clim', [-1 1])
colorbar; title('time = 0 msec')

figure(2)
plotOnEgi([r1Mean(:,t80); nan(4,1)])
set(gca, 'clim', [-1 1])
colorbar; title('time = 80 msec')

figure(3)
plotOnEgi([r1Mean(:,t176); nan(4,1)])
set(gca, 'clim', [-1 1])
colorbar; title('time = 176 msec')

%% Try randomizing the labels

rr = computeSpaceTimeReliability(X, labels72(randperm(length(labels72))), 100);
rr_96 = squeeze(rr(96,:,:));
close all
plot(t,mean(rr_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(t,mean(rr_96,2)+std(rr_96,[],2), 'b')
plot(t,mean(rr_96,2)-std(rr_96,[],2), 'b')

%% Try 2D input - ch 96 all time
clc
x96 = squeeze(X(96,:,:))'; % Trial x feature

% This one inputs the data as a 2D matrix
r2d_1 = computeSpaceTimeReliability(x96, labels72, 10, 1);

% This one inputs the data as a 3D matrix with singleton first dimension
r2d_2 = computeSpaceTimeReliability(X(96,:,:), labels72, 10, 1);

% This one inputs the data as a 3D matrix and we'll subset after
r2d_3 = computeSpaceTimeReliability(X, labels72, 10, 1);

assert(isequal(r2d_1, r2d_2));
disp('success 1 vs 2') % OK
assert(isequal(r2d_1, squeeze(r2d_3(96,:,:))));
disp('success 1 vs 3') % Fails

%% Try 2D input - ch 1 all time
clc
x1 = squeeze(X(1,:,:))'; % Trial x feature

% This one inputs the data as a 2D matrix
r2d_1 = computeSpaceTimeReliability(x1, labels72, 10, 1);

% This one inputs the data as a 3D matrix with singleton first dimension
r2d_2 = computeSpaceTimeReliability(X(1,:,:), labels72, 10, 1);

% This one inputs the data as a 3D matrix and we'll subset after
r2d_3 = computeSpaceTimeReliability(X, labels72, 10, 1);

assert(isequal(r2d_1, r2d_2));
disp('success 1 vs 2') % OK
assert(isequal(r2d_1, squeeze(r2d_3(1,:,:))));
disp('success 1 vs 3') % Fails

%% Try 2D input - all time one time point
clc
x1 = squeeze(X(:,19,:))'; % Trial x feature

% This one inputs the data as a 2D matrix
r2d_1 = computeSpaceTimeReliability(x1, labels72, 10, 1);

% This one inputs the data as a 3D matrix and we'll subset after
r2d_3 = computeSpaceTimeReliability(X, labels72, 10, 1);

assert(isequal(r2d_1, squeeze(r2d_3(:,19,:))));
disp('success 1 vs 3') % Fails

close all
plot(mean(r2d_1,2), 'b', 'linewidth', 2); grid on; hold on
blah = squeeze(r2d_3(:,19,:));
plot(mean(blah, 2), 'r', 'linewidth', 2);

%% Try 6-class case (3D input)
r6 = computeSpaceTimeReliability(X, labels6, 100);
r1_96 = squeeze(r6(96,:,:));

close
plot(t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(t,mean(r1_96,2)-std(r1_96,[],2), 'b')