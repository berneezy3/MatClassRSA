% test_v2_Reliability_testComputeSpaceTimeReliability.m
% -------------------------------------
% Ray - Febuary 2022

clear all; close all; clc

% The following datasets were added to "UnitTests" folder: "lsosorelli_100sweep_epoched.mat",
% "lsosorelli_500sweep_epoched.mat", "S01.mat"
run('loadUnitTestData.m') 

RSA = MatClassRSA;

%% 3D input balanced 72-class labels -- looks good
close
r = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72, 100, []);
r1_96 = squeeze(r(96,:,:));
r1_70 = squeeze(r(70,:,:));
r1_20 = squeeze(r(20,:,:));
r1_36 = squeeze(r(36,:,:));

subplot(2,2,1)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(S01.t,mean(r1_96,2)-std(r1_96,[],2), 'b')

title('Electrode 96')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,2)
plot(S01.t,mean(r1_70,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_70,2)+std(r1_70,[],2), 'b')
plot(S01.t,mean(r1_70,2)-std(r1_70,[],2), 'b')

title('Electrode 70')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,3)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_20,2)+std(r1_20,[],2), 'b')
plot(S01.t,mean(r1_20,2)-std(r1_20,[],2), 'b')

title('Electrode 20')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,4)
plot(S01.t,mean(r1_36,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_36,2)+std(r1_36,[],2), 'b')
plot(S01.t,mean(r1_36,2)-std(r1_36,[],2), 'b')

title('Electrode 36')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Balanced Space Time Reliability') 

%% Visualize reliabilities on a topoplot -- looks good

t0 = find(S01.t==0);
t80 = find(S01.t==80);
t176 = find(S01.t==176);

r1Mean = mean(r,3);
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

%% 3D input slightly unbalanced 72-class labels -- looks good
close all; clear r;
r = RSA.Reliability.computeSpaceTimeReliability(S01_72class_slightlyUnbalanced.X, S01_72class_slightlyUnbalanced.labels72, 100, []);
r1_96 = squeeze(r(96,:,:));
r1_70 = squeeze(r(70,:,:));
r1_20 = squeeze(r(20,:,:));
r1_36 = squeeze(r(36,:,:));

subplot(2,2,1)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(S01.t,mean(r1_96,2)-std(r1_96,[],2), 'b')

title('Electrode 96')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,2)
plot(S01.t,mean(r1_70,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_70,2)+std(r1_70,[],2), 'b')
plot(S01.t,mean(r1_70,2)-std(r1_70,[],2), 'b')

title('Electrode 70')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,3)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_20,2)+std(r1_20,[],2), 'b')
plot(S01.t,mean(r1_20,2)-std(r1_20,[],2), 'b')

title('Electrode 20')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,4)
plot(S01.t,mean(r1_36,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_36,2)+std(r1_36,[],2), 'b')
plot(S01.t,mean(r1_36,2)-std(r1_36,[],2), 'b')

title('Electrode 36')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Slightly Unbalanced Space Time Reliability')

%% 3D input very unbalanced 72-class labels -- looks good
close all; clear r;
r = RSA.Reliability.computeSpaceTimeReliability(S01_72class_veryUnbalanced.X, S01_72class_veryUnbalanced.labels72, 100, []);
r1_96 = squeeze(r(96,:,:));
r1_70 = squeeze(r(70,:,:));
r1_20 = squeeze(r(20,:,:));
r1_36 = squeeze(r(36,:,:));

subplot(2,2,1)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(S01.t,mean(r1_96,2)-std(r1_96,[],2), 'b')

title('Electrode 96')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,2)
plot(S01.t,mean(r1_70,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_70,2)+std(r1_70,[],2), 'b')
plot(S01.t,mean(r1_70,2)-std(r1_70,[],2), 'b')

title('Electrode 70')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,3)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_20,2)+std(r1_20,[],2), 'b')
plot(S01.t,mean(r1_20,2)-std(r1_20,[],2), 'b')

title('Electrode 20')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,4)
plot(S01.t,mean(r1_36,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_36,2)+std(r1_36,[],2), 'b')
plot(S01.t,mean(r1_36,2)-std(r1_36,[],2), 'b')

title('Electrode 36')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Very Unbalanced Space Time Reliability')

%% 3D input low count unbalanced 72-class labels -- looks good
close all; clear r;
r = RSA.Reliability.computeSpaceTimeReliability(S01_72class_lowCountUnbalanced.X, S01_72class_lowCountUnbalanced.labels72, 100, []);
r1_96 = squeeze(r(96,:,:));
r1_70 = squeeze(r(70,:,:));
r1_20 = squeeze(r(20,:,:));
r1_36 = squeeze(r(36,:,:));

subplot(2,2,1)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(S01.t,mean(r1_96,2)-std(r1_96,[],2), 'b')

title('Electrode 96')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,2)
plot(S01.t,mean(r1_70,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_70,2)+std(r1_70,[],2), 'b')
plot(S01.t,mean(r1_70,2)-std(r1_70,[],2), 'b')

title('Electrode 70')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,3)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_20,2)+std(r1_20,[],2), 'b')
plot(S01.t,mean(r1_20,2)-std(r1_20,[],2), 'b')

title('Electrode 20')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,4)
plot(S01.t,mean(r1_36,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_36,2)+std(r1_36,[],2), 'b')
plot(S01.t,mean(r1_36,2)-std(r1_36,[],2), 'b')

title('Electrode 36')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Low Count Unbalanced Space Time Reliability')

%% 3D input balanced 72-class labels, blank for rng (3 input arguments) -- looks good
close all; clear r;
r = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72, 100);

%% 3D input balanced 6-class labels -- to me this looks strange
close all; clear r;
r = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels6, 100, []);
r1_96 = squeeze(r(96,:,:));
r1_70 = squeeze(r(70,:,:));
r1_20 = squeeze(r(20,:,:));
r1_36 = squeeze(r(36,:,:));

subplot(2,2,1)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_96,2)+std(r1_96,[],2), 'b')
plot(S01.t,mean(r1_96,2)-std(r1_96,[],2), 'b')

title('Electrode 96')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,2)
plot(S01.t,mean(r1_70,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_70,2)+std(r1_70,[],2), 'b')
plot(S01.t,mean(r1_70,2)-std(r1_70,[],2), 'b')

title('Electrode 70')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,3)
plot(S01.t,mean(r1_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_20,2)+std(r1_20,[],2), 'b')
plot(S01.t,mean(r1_20,2)-std(r1_20,[],2), 'b')

title('Electrode 20')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(2,2,4)
plot(S01.t,mean(r1_36,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r1_36,2)+std(r1_36,[],2), 'b')
plot(S01.t,mean(r1_36,2)-std(r1_36,[],2), 'b')

title('Electrode 36')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Low Count Unbalanced Space Time Reliability')

%% 3D full input, 3D single electrode input (96), and 2D input (96), balanced 72-class labels -- looks good

close all; clear r;

X2d = squeeze(S01.X(96,:,:))'; % Trial by time
r2D = RSA.Reliability.computeSpaceTimeReliability(X2d, S01.labels72, 100, 1);

r3D = RSA.Reliability.computeSpaceTimeReliability(S01.X(96,:,:), S01.labels72, 100, 1);

r3DFull = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72, 100, 1);
r3D_1 = squeeze(r3DFull(96,:,:));


subplot(1,3,1)
plot(S01.t,mean(r2D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r2D,2)+std(r2D,[],2), 'b')
plot(S01.t,mean(r2D,2)-std(r2D,[],2), 'b')

title('2D')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,2)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D,2)+std(r3D,[],2), 'b')
plot(S01.t,mean(r3D,2)-std(r3D,[],2), 'b')

title('3D Single Electrode Input')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,3)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D_1,2)+std(r3D_1,[],2), 'b')
plot(S01.t,mean(r3D_1,2)-std(r3D_1,[],2), 'b')

title('3D Full Input')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D vs 2D Single Electrode Input (96)')

assert(isequal(r2D, r3D));
disp('2D and 3D single electrode input show same reliability') % OK

assert(isequal(r3D, r3D_1));
disp('3D full input and 3D single electrode input show same reliability') % Failed

%% 3D full input, 3D single electrode input (96), and 2D input (96), balanced 72-class labels, blank rng ({'shuffle','twister'}) -- reliabilities do not match

close all; clear r;

X2d = squeeze(S01.X(96,:,:))'; % Trial by time
r2D = RSA.Reliability.computeSpaceTimeReliability(X2d, S01.labels72, 100, []);

r3D = RSA.Reliability.computeSpaceTimeReliability(S01.X(96,:,:), S01.labels72, 100, []);

r3DFull = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72, 100, []);
r3D_1 = squeeze(r3DFull(96,:,:));


subplot(1,3,1)
plot(S01.t,mean(r2D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r2D,2)+std(r2D,[],2), 'b')
plot(S01.t,mean(r2D,2)-std(r2D,[],2), 'b')

title('2D')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,2)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D,2)+std(r3D,[],2), 'b')
plot(S01.t,mean(r3D,2)-std(r3D,[],2), 'b')

title('3D Single Electrode Input')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,3)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D_1,2)+std(r3D_1,[],2), 'b')
plot(S01.t,mean(r3D_1,2)-std(r3D_1,[],2), 'b')

title('3D Full Input')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D vs 2D Single Electrode Input (96)')

assert(isequal(r2D, r3D));
disp('2D and 3D single electrode input show same reliability') % Failed

assert(isequal(r3D, r3D_1));
disp('3D full input and 3D single electrode input show same reliability') % Failed

%% 3D full input, 3D single electrode input (96), and 2D input (96), slightly unbalanced 72-class labels -- looks good

close all; clear r;

X2d = squeeze(S01_72class_slightlyUnbalanced.X(96,:,:))'; % Trial by time
r2D = RSA.Reliability.computeSpaceTimeReliability(X2d, S01_72class_slightlyUnbalanced.labels72, 100, 1);

r3D = RSA.Reliability.computeSpaceTimeReliability(S01_72class_slightlyUnbalanced.X(96,:,:), S01_72class_slightlyUnbalanced.labels72, 100, 1);

r3DFull = RSA.Reliability.computeSpaceTimeReliability(S01_72class_slightlyUnbalanced.X, S01_72class_slightlyUnbalanced.labels72, 100, 1);
r3D_1 = squeeze(r3DFull(96,:,:));


subplot(1,3,1)
plot(S01.t,mean(r2D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r2D,2)+std(r2D,[],2), 'b')
plot(S01.t,mean(r2D,2)-std(r2D,[],2), 'b')

title('2D (ch. 96)')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,2)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D,2)+std(r3D,[],2), 'b')
plot(S01.t,mean(r3D,2)-std(r3D,[],2), 'b')

title('3D Single Electrode Input (ch. 96)')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,3)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D_1,2)+std(r3D_1,[],2), 'b')
plot(S01.t,mean(r3D_1,2)-std(r3D_1,[],2), 'b')

title('3D Full Input (ch. 96)')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D Full, 3D Single Electrode, and 2D Input Slightly Unbalanced')

assert(isequal(r2D, r3D));
disp('2D and 3D single electrode input show same reliability') % OK

assert(isequal(r3D, r3D_1));
disp('3D full input and 3D single electrode input show same reliability') % Failed

%% 3D full input, 3D single electrode input (1), and 2D input (1), balanced 72-class labels -- looks good

close all; clear r;

X2d = squeeze(S01.X(1,:,:))'; % Trial by time
r2D = RSA.Reliability.computeSpaceTimeReliability(X2d, S01.labels72, 100, 1);

r3D = RSA.Reliability.computeSpaceTimeReliability(S01.X(1,:,:), S01.labels72, 100, 1);

r3DFull = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72, 100, 1);
r3D_1 = squeeze(r3DFull(1,:,:));


subplot(1,3,1)
plot(S01.t,mean(r2D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r2D,2)+std(r2D,[],2), 'b')
plot(S01.t,mean(r2D,2)-std(r2D,[],2), 'b')

title('2D')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,2)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D,2)+std(r3D,[],2), 'b')
plot(S01.t,mean(r3D,2)-std(r3D,[],2), 'b')

title('3D Single Electrode Input')
xlabel('Time (ms)');
ylabel('Reliability');

subplot(1,3,3)
plot(S01.t,mean(r3D,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(r3D_1,2)+std(r3D_1,[],2), 'b')
plot(S01.t,mean(r3D_1,2)-std(r3D_1,[],2), 'b')

title('3D Full Input')
xlabel('Time (ms)');
ylabel('Reliability');

sgtitle('3D vs 2D Single Electrode Input (1)')

assert(isequal(r2D, r3D));
disp('2D and 3D single electrode input show same reliability') % OK

assert(isequal(r3D, r3D_1));
disp('3D full input and 3D single electrode input show same reliability') % Failed

%% Test rng blank -- looks good
r = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72);
rng

%% Test rng user specified -- looks good

[r1] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], {'shuffle', 'philox'});
rng


[r2] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], {1, 'philox'});
rng


r3 = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], {'shuffle', 'twister'});
rng

%% Test string array-- looks good
rng(42, 'philox')
rng
r4 = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], ["shuffle", "twister"]);
rng
 
 %% Test with bad rng -- looks good
 
[r] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], {'2', '1'});
%there is an error

%% Test with single-input rng -- looks good

[r] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, [], 25);
rng

%% Set number of permutations to nPerms -- looks good
nPerms = 16;

[r] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, nPerms);
assert(isequal(size(r), [124 6 nPerms]))
disp('Success')

%This was carried over from previous unit test. Now an error is thrown, as
%demonstrated above for too few input arguments.

%% Set number of permutations to nPerms -- looks good
nPerms = 16;

[r] = RSA.Reliability.computeSpaceTimeReliability(S01.X(:,20:25,:), S01.labels72, nPerms, []);
assert(isequal(size(r), [124 6 nPerms]))
disp('Success')

%% Try randomizing the labels -- seems reasonable

rr = RSA.Reliability.computeSpaceTimeReliability(S01.X, S01.labels72(randperm(length(S01.labels72))), [], []);
rr_96 = squeeze(rr(96,:,:));
close all
plot(S01.t,mean(rr_96,2), 'b', 'linewidth', 2);
hold on; grid on
plot(S01.t,mean(rr_96,2)+std(rr_96,[],2), 'b')
plot(S01.t,mean(rr_96,2)-std(rr_96,[],2), 'b')

