% loadUnitTestData.m
% --------------------------
% Blair - January 2022
%
% Script (not a function) to load and manipulate test datasets. The four
% datasets of interest need to be in the path (can add to "UnitTests"
% folder; git will ignore).
%
% Create different forms of data/labels:
% - Original (complete - higher number of total trials)
% - Higher total trials - slightly unbalanced classes
% - Higher total trials - very unbalanced classes
% - Low trial count with balanced classes
% - Low trial count with slightly unbalanced classes

%% Load the testing data .mat files and save each one in a struct
% (This is the original data and labels)

SL100 = load('losorelli_100sweep_epoched.mat');
% struct with fields:
%
%     P: [1×1950 double]        // participant ids
%     X: [1950×2801 double]     // 2D data
%     Y: [1×1950 double]        // labels
%     t: [2801×1 double]

SL500 = load('losorelli_500sweep_epoched.mat');
%   struct with fields:
%
%     P: [390×1 double]         // participant ids
%     X: [390×2801 double]      // 2D data
%     Y: [390×1 double]         // labels
%     t: [2801×1 double]

S01 = load('S01.mat');
%   struct with fields:
%
%                X: [124×40×5184 double]            // 3D data
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [1×5184 double]                 // 6-class labels
%         labels72: [1×5184 double]                 // 72-class labels
%            subID: '01'
%                t: [1×40 double]

%% Higher total trials with slightly unbalanced classes

% Delete this many observations from each class
tempDelete = [0 10 6 7 3 12];

%%%%% SL100 %%%%%%
unique(SL100.Y);        % Integers [1 2 3 4 5 6]
tempCounts = histcounts(SL100.Y, 'BinMethod', 'integers');
% Classes are balanced, all have 325 observations

% Initialize the new data struct
SL100_slightlyImbalanced = SL100;

% Introduce slight imbalances
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(SL100_slightlyImbalanced.Y == i);
    
    % Vector of first however many observations to delete for this stim
    thisDelete = thisIdx(1:tempDelete(i)); % 0 value is ok -- returns empty vector
    
    % Remove the first however many from P, X, Y
    SL100_slightlyImbalanced.P(thisDelete) = [];
    SL100_slightlyImbalanced.X(thisDelete, :) = [];
    SL100_slightlyImbalanced.Y(thisDelete) = [];
    
    clear this*
end

tempCounts = histcounts(SL100_slightlyImbalanced.Y, 'BinMethod', 'integers');
% Looks right: [325   315   319   318   322   313]
SL100_slightlyImbalanced
%     P: [1×1874 double]
%     X: [1874×2801 double]
%     Y: [1×1874 double]
%     t: [2801×1 double]

%%%%%% SL500 %%%%%%
unique(SL500.Y);        % Integers [1 2 3 4 5 6]'
tempCounts = histcounts(SL500.Y, 'BinMethod', 'integers');
% Classes are balanced, all have 65 observations

% Initialize the new data struct
SL500_slightlyImbalanced = SL500;

% Introduce slight imbalances
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(SL500_slightlyImbalanced.Y == i);
%     length(thisIdx)
    
    % Vector of first however many observations to delete for this stim
    thisDelete = thisIdx(1:tempDelete(i)); % 0 value is ok -- returns empty vector
    
    % Remove the first however many from P, X, Y
    SL500_slightlyImbalanced.P(thisDelete) = [];
    SL500_slightlyImbalanced.X(thisDelete, :) = [];
    SL500_slightlyImbalanced.Y(thisDelete) = [];
    
    clear this*
end

tempCounts = histcounts(SL500_slightlyImbalanced.Y, 'BinMethod', 'integers');
% Looks right: [65    55    59    58    62    53]
SL500_slightlyImbalanced
%     P: [352×1 double]
%     X: [352×2801 double]
%     Y: [352×1 double]
%     t: [2801×1 double]

%%%%%% S01 - 6 class %%%%%%
unique(S01.labels6);         % Integers [1 2 3 4 5 6]
tempCounts = histcounts(S01.labels6, 'BinMethod', 'integers');
% Classes are balanced, all 864 observations

% Initialize new data struct
S01_6class_slightlyUnbalanced = S01;

% Introduce slight imbalances
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(S01_6class_slightlyUnbalanced.labels6 == i);
    length(thisIdx);
    
    % Vector of first N obs to delete 
    thisDelete = thisIdx(1:tempDelete(i));
    
    % Rm those obs
    S01_6class_slightlyUnbalanced.X(:, :, thisDelete) = [];
    S01_6class_slightlyUnbalanced.labels6(thisDelete) = [];
    
    clear this*
    
end

tempCounts = histcounts(S01_6class_slightlyUnbalanced.labels6, 'BinMethod', 'integers');
% Looks right: [864   854   858   857   861   852]
S01_6class_slightlyUnbalanced = rmfield(S01_6class_slightlyUnbalanced, 'labels72')
%                X: [124×40×5146 double]
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [1×5146 double]
%            subID: '01'
%                t: [1×40 double]

%%%%%% S01 - 72 class %%%%%%
unique(S01.labels72);         % Integers 1:72
tempCounts = histcounts(S01.labels72, 'BinMethod', 'integers');
% Classes are balanced, all 72 observations

% Initialize new data struct
S01_72class_slightlyUnbalanced = S01;

% Introduce slight imbalances -- rotating between 0 and 6 per class 
for i = 1:72
    
    % Get indices of current stim
    thisIdx = find(S01_72class_slightlyUnbalanced.labels72 == i);
    length(thisIdx);
    
    % Vector of first N obs to delete 
    thisDelete = thisIdx(1:mod(i, 7));
    
    % Rm those obs
    S01_72class_slightlyUnbalanced.X(:, :, thisDelete) = [];
    S01_72class_slightlyUnbalanced.labels72(thisDelete) = [];
    
    clear this*
    
end

tempCounts = histcounts(S01_72class_slightlyUnbalanced.labels72, 'BinMethod', 'integers');
% Looks right
S01_72class_slightlyUnbalanced = rmfield(S01_72class_slightlyUnbalanced, 'labels6')
%                X: [124×40×5146 double]
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [1×5146 double]
%            subID: '01'
%                t: [1×40 double]

clear temp* ans i


%% Higher total trials with very unbalanced classes

%%%%% SL100 %%%%%%
unique(SL100.Y);        % Integers [1 2 3 4 5 6]
tempCounts = histcounts(SL100.Y, 'BinMethod', 'integers');
% Classes are balanced, all have 325 observations

% Delete this many observations from each class
tempDelete = [100 0 0 0 0 100];

% Initialize the new data struct
SL100_veryImbalanced = SL100;

% Introduce large imbalances to class 1 (high confuse) and 6 (high acc)
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(SL100_veryImbalanced.Y == i);
    
    % Vector of first however many observations to delete for this stim
    thisDelete = thisIdx(1:tempDelete(i)); % 0 value is ok -- returns empty vector
    
    % Remove the first however many from P, X, Y
    SL100_veryImbalanced.P(thisDelete) = [];
    SL100_veryImbalanced.X(thisDelete, :) = [];
    SL100_veryImbalanced.Y(thisDelete) = [];
    
    clear this*
end

tempCounts = histcounts(SL100_veryImbalanced.Y, 'BinMethod', 'integers')
% Looks right: [225   325   325   325   325   225]
SL100_veryImbalanced
%     P: [1×1750 double]
%     X: [1750×2801 double]
%     Y: [1×1750 double]
%     t: [2801×1 double]

%%%%%% SL500 %%%%%%
unique(SL500.Y);        % Integers [1 2 3 4 5 6]'
tempCounts = histcounts(SL500.Y, 'BinMethod', 'integers');
% Classes are balanced, all have 65 observations

% Delete this many observations from each class
tempDelete = [30 0 0 0 0 30];

% Initialize the new data struct
SL500_veryImbalanced = SL500;

% Introduce large imbalances to class 1 (high confuse) and 6 (high acc)
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(SL500_veryImbalanced.Y == i);
%     length(thisIdx)
    
    % Vector of first however many observations to delete for this stim
    thisDelete = thisIdx(1:tempDelete(i)); % 0 value is ok -- returns empty vector
    
    % Remove the first however many from P, X, Y
    SL500_veryImbalanced.P(thisDelete) = [];
    SL500_veryImbalanced.X(thisDelete, :) = [];
    SL500_veryImbalanced.Y(thisDelete) = [];
    
    clear this*
end

tempCounts = histcounts(SL500_veryImbalanced.Y, 'BinMethod', 'integers')
% Looks right: [35    65    65    65    65    35]
SL500_veryImbalanced
%     P: [330×1 double]
%     X: [330×2801 double]
%     Y: [330×1 double]
%     t: [2801×1 double]

%%%%%% S01 - 6 class %%%%%%
unique(S01.labels6);         % Integers [1 2 3 4 5 6]
tempCounts = histcounts(S01.labels6, 'BinMethod', 'integers');
% Classes are balanced, all 864 observations

% Delete this many observations from each class
tempDelete = [0 400 0 0 0 400];

% Initialize new data struct
S01_6class_veryUnbalanced = S01;

% Introduce large imbalances to class 2 (high acc) and 6 (high confuse)
for i = 1:6
    
    % Get indices of current stim
    thisIdx = find(S01_6class_veryUnbalanced.labels6 == i);
    length(thisIdx);
    
    % Vector of first N obs to delete 
    thisDelete = thisIdx(1:tempDelete(i));
    
    % Rm those obs
    S01_6class_veryUnbalanced.X(:, :, thisDelete) = [];
    S01_6class_veryUnbalanced.labels6(thisDelete) = [];
    
    clear this*
    
end

tempCounts = histcounts(S01_6class_veryUnbalanced.labels6, 'BinMethod', 'integers')
% Looks right: [864   854   858   857   861   852]
S01_6class_veryUnbalanced = rmfield(S01_6class_veryUnbalanced, 'labels72')
%                X: [124×40×5146 double]
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [1×5146 double]
%            subID: '01'
%                t: [1×40 double]

%%% TODO START HERE %%%
%%%%%% S01 - 72 class %%%%%%
unique(S01.labels72);         % Integers 1:72
tempCounts = histcounts(S01.labels72, 'BinMethod', 'integers')
% Classes are balanced, all 72 observations

% Initialize new data struct
S01_72class_veryUnbalanced = S01;

% Introduce slight imbalances -- rotating between 0 and 6 per class 
for i = 1:72
    
    % Get indices of current stim
    thisIdx = find(S01_72class_veryUnbalanced.labels72 == i);
    length(thisIdx);
    
    % Vector of first N obs to delete 
    thisDelete = thisIdx(1:(mod(i, 2) * 36));
    
    % Rm those obs
    S01_72class_veryUnbalanced.X(:, :, thisDelete) = [];
    S01_72class_veryUnbalanced.labels72(thisDelete) = [];
    
    clear this*
    
end

tempCounts = histcounts(S01_72class_veryUnbalanced.labels72, 'BinMethod', 'integers')
% Looks right
S01_72class_veryUnbalanced = rmfield(S01_72class_veryUnbalanced, 'labels6')
%                X: [124×40×5146 double]
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [1×5146 double]
%            subID: '01'
%                t: [1×40 double]

clear temp* ans i

