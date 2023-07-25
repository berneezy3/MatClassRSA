% example_v2_preprocessing_shuffleData.m
% --------------------------------------
% Example code for shuffling trials using
% shuffleData.m
%
% This script covers the following steps:
%   - Clearing workspace
%   - Setting random number generator type and seed
%   - Loading 2D data
%   - Instantiating MatClassRSA object
%   - Shuffling data
%   - Visualizing shuffled trials and grand average
%   - Visualizing shuffled participants and participant average

% Ray - April, 2022

% clear console, figures, and workspace
clear all; close all; clc

% set random number generator seed
rnd_seed = 0;

% load two dimensional dataset (trial X time)
load('losorelli_100sweep_epoched.mat')

% Make MatClassRSA object
RSA = MatClassRSA;

% Run shuffleData.m with 2D EEG data, 6-class labels vector, participant vector, and random seed set to rnd_seed.
[X_shuf, Y_shuf, P_shuf, rndIdx] = RSA.Preprocessing.shuffleData(X, Y, P, 'randomSeed', rnd_seed);

% visualize shuffled trials and grand average
figure(1);
subplot(2,1,1);
plot(Y, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Unshuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');

hold on;
subplot(2,1,2);
plot(Y_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Shuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');

figure(2);
subplot(2,1,1);
sgtitle('Grand Average');
plot(t, mean(X,1), 'color', 'r',...
    'linewidth', 1);
ylabel('\mu V');
xlabel('time (ms)');
grid on;
title('Before Shuffle');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(t, mean(X,1), 'color', 'r',...
    'linewidth', 1);
ylabel('\mu V'); 
xlabel('time (ms)');
grid on;
title('After Shuffle');
set(gca, 'fontsize', 12)


% visualize shuffled participants and participant average
figure(3);
subplot(2,1,1);
plot(P, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Unshuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');

hold on;
subplot(2,1,2);
plot(P_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Shuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');

figure(4);
subplot(2,1,1);
sgtitle('Participant Averages');
for i = 1:13
        temp = squeeze(mean(X(P==i,:),1));
        plot(t, temp);
        hold on;     
end
ylabel('\mu V'); 
grid on;
xlabel('time (ms)');
title('Before Shuffle');
set(gca, 'fontsize', 12)
legend('1','2','3','4','5','6','7','8','9','10','11','12','13');
hold on;

subplot(2,1,2);
for i = 1:13
        temp = squeeze(mean(X_shuf(P_shuf==i,:),1));
        plot(t, temp);
        hold on;     
end
ylabel('\mu V');
xlabel('time (ms)');
grid on;
title('After Shuffle');
set(gca, 'fontsize', 12)
















