% test_v2_Reliability_ComputeSampleSizeReliability.m
% -------------------------------------------
% Ray - Febuary, 2022

clear all; close all; clc

% Add the following datasets to "UnitTests" folder: "lsosorelli_100sweep_epoched.mat",
% "lsosorelli_500sweep_epoched.mat","S01.mat"
run('loadUnitTestData.m') 

RSA = MatClassRSA;

%% 3D input balanced 72 class-labels -- looks good
r = RSA.Reliability.computeSampleSizeReliability(S01.X, S01.labels72, 19, 1:11);
rMean = squeeze(mean(r,1));
close all
plot(rMean(:,96), 'linewidth', 2); grid on

title('3D Balanced Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D input slightly unbalanced 72 class-labels -- looks good
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(S01_72class_slightlyUnbalanced.X, S01_72class_slightlyUnbalanced.labels72, 19, 1:11);
rMean = squeeze(mean(r,1));

plot(rMean(:,96), 'linewidth', 2); grid on

title('3D Slightly Unbalanced Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D input very unbalanced 72 class-lables -- looks good
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(S01_72class_veryUnbalanced.X, S01_72class_veryUnbalanced.labels72, 19, 1:11);
rMean = squeeze(mean(r,1));

plot(rMean(:,96), 'linewidth', 2); grid on

title('3D Very Unbalanced Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D input balanced, 72-class labels, single channel (96), bad time point -- xx acting strange xx
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 1, 1:36, [], [], 1);
rMean = mean(r, 1);

plot(rMean, 'linewidth', 2); grid on
title('3D Balanced Sample Size Reliability Bad Time Point')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D and 2D input, single electrode (96), 72 class-labels, good time point -- looks good
close all; clear r;
r3D = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, 1:20,...
    [], [], 1);

% r3 is 10 perm x 20 trials in split
rMean3D = mean(r3D, 1);

% 2D input on S01 channel 96 should match single electrode

X2d = squeeze(S01.X(96,:,:))'; % Trial by time
r2D = RSA.Reliability.computeSampleSizeReliability(X2d, S01.labels72, 19, 1:20,...
    [], [], 1);

rMean2D = mean(r2D, 1);

subplot(1,2,1)
plot(rMean3D, 'linewidth', 2); grid on
title('3D Single Electrode Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

subplot(1,2,2)
plot(rMean2D, 'linewidth', 2); grid on
title('2D Single Electrode Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

assert(isequal(r3D, r2D)); 
disp('3D input single electrode equals 2D input')

%% 3D input balanced, 6-class labels -- xx acting strange xx 
close all; clear r;

r = RSA.Reliability.computeSampleSizeReliability(S01.X, S01.labels6, 1, 1:20, [], [], 1);
rMean = squeeze(mean(r,1));

plot(rMean(:,96), 'linewidth', 2); grid on
title('3D Balanced Sample Size Reliability 6-Class')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D input slightly unbalanced, 6-class labels -- xx acting strange xx 
close all; clear r;

r = RSA.Reliability.computeSampleSizeReliability(S01_6class_slightlyUnbalanced.X, S01_6class_slightlyUnbalanced.labels6, 1, 1:20, [], [], 1);
rMean = squeeze(mean(r,1));

plot(rMean(:,96), 'linewidth', 2); grid on
title('3D Slightly Unbalanced Sample Size Reliability 6-Class')
xlabel('Sample Size n');
ylabel('Reliability');

%% 3D input very unbalanced, 6-class labels -- xx acting strange xx 
close all; clear r;

r = RSA.Reliability.computeSampleSizeReliability(S01_6class_veryUnbalanced.X, S01_6class_veryUnbalanced.labels6, 1, 1:20, [], [], 1);
rMean = squeeze(mean(r,1));

plot(rMean(:,96), 'linewidth', 2); grid on
title('3D Very Unbalanced Sample Size Reliability 6-Class')
xlabel('Sample Size n');
ylabel('Reliability');


%% 3D input balanced, 6-class labels, single channel (96)-- xx acting strange xx
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels6, 25, 1:36, [], [], 1);
rMean = mean(r, 1);

plot(rMean, 'linewidth', 2); grid on
title('3D Balanced Single Electrode Sample Size Reliability 6-Class')
xlabel('Sample Size n');
ylabel('Reliability');

%% 2D input (SL100) balanced -- xx acting strange xx
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(SL100.X, SL100.Y, 1, 1:36, [], [], 1);
rMean = mean(r, 1);

plot(rMean, 'linewidth', 2); grid on
title('2D Balanced Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

%% 2D input (SL500) balanced -- xx acting strange xx
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(SL500.X, SL500.Y, 1, 1:36, [], [], 1);
rMean = mean(r, 1);

plot(rMean, 'linewidth', 2); grid on
title('2D Balanced Sample Size Reliability')
xlabel('Sample Size n');
ylabel('Reliability');

%% Testing rng - not sure how to interpret

close; clc
rng(42, 'philox')
rng
r1 = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, [], [], [], 1);
rng

rng(42, 'philox')
rng
r2 = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, [], [], [], 'default');
rng

rng(42, 'philox')
rng
r3 = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, [], [], [], {'shuffle', 'twister'});
rng

rng(42, 'philox')
rng
r4 = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, [], [], [], ["shuffle", "twister"]);
rng

rng(42, 'philox')
rng
r5 = RSA.Reliability.computeSampleSizeReliability(S01.X(96,:,:), S01.labels72, 19, [], [], []);
rng

assert(isequal(r1, r2)); 
disp("Reliability using random number generator seed is replicable for 'default' and '1'")
assert(isequal(r3, r4)); 
disp("Reliability using random number generator seed is replicable for '{' and '[' calls")
assert(isequal(r1, r2, r3, r4, r5)); 
disp("Reliability replicable for both user specified and default calls")

%% 3D input with ntrials in split too large -- ** feature request **
close all; clear r;
r = RSA.Reliability.computeSampleSizeReliability(S01.X, S01.labels72, 19, [1000 1]);

split1 = squeeze(r(:,1,:));
split2 = squeeze(r(:,2,:));
n = numel(split1);

assert(isequal(n, sum(isnan(split1(:)))));
disp('success: first split output is all nan.')

assert(isequal(sum(isnan(split2(:))), 0));
disp('success: second split output contains no nans.')