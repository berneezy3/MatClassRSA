% example_v2_preprocessing_shuffleData.m
% --------------------------------------
% Example code for shuffling trials using
% shuffleData.m
%
% This script covers the following steps:
%   - Clearing workspace
%   - Setting random number generator type and seed
%   - Loading 2D data
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

% Run shuffleData.m with 2D EEG data, 6-class labels vector, participant vector, and random seed set to rnd_seed.
[X_shuf, Y_shuf, P_shuf, rndIdx] = Preprocessing.shuffleData(X, Y, P, 'rngType', rnd_seed);

% visualize shuffled trials and grand average
figure(1);
set(gcf, 'Position', [410,550,455,455]);
subplot(2,1,1);
sgtitle('Shuffling of Classes');
plot(Y, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Unshuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(Y_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Shuffled Classes");
ylabel('Category Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

figure(2);
set(gcf, 'Position', [867,550,455,455]);
subplot(2,1,1);
sgtitle('Grand Average Across All Classes');
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

annotation ('textbox', [0.73, 0.3, 0.25, 0.25], ...
    'String', {
        'Shuffling classes does not impact data integrity'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');



% visualize shuffled participants and participant average
figure(3);
set(gcf, 'Position', [410,10,455,455]);
subplot(2,1,1);
sgtitle('Shuffling of Participants');
plot(P, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Unshuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

hold on;
subplot(2,1,2);
plot(P_shuf, 'b', 'linewidth', 2,'linestyle','none', 'marker', 'x');
title("Shuffled Participants");
ylabel('Participant Label');
xlabel('Trial Number');
set(gca, 'fontsize', 12)

figure(4);
set(gcf, 'Position', [867,10,455,455]);
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
set(gca, 'fontsize', 12)
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

annotation ('textbox', [0.73, 0.3, 0.25, 0.25], ...
    'String', {
        'Shuffling participants does impact data integrity'},...
    'FontSize', 16, ...
    'EdgeColor','none', ...
    'BackgroundColor', [173/255, 216/255, 230/255], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');
















