% scratch_bkClassificationTests_20220215.m
% --------------------------------------------
% Blair - Feb 15, 2022
%
% Some classification runs that worked for me during our Feb 15 call.
% MatClassRSA already in path.

clear all; close all; clc
load S06.mat
MCR = MatClassRSA;

%% Classification with < 800 trials total
xUse = X(:,:,1:799);
yUse = labels6(1:799);
MCR.Classification.crossValidateMulti(xUse, yUse)
ans.CM
% ans =
% 
%     33    13    17    22    26    23
%      9    50    16    12    24    23
%     19    20    35    28    17    14
%     23    17    31    22    22    18
%     26    16    16    16    37    22
%     23    22    19    18    22    28

%% Same as above with LDA classifier specified

MCR.Classification.crossValidateMulti(xUse, yUse, 'classifier', 'lda')
ans.CM
% ans =
% 
%     33    13    17    22    26    23
%      9    50    16    12    24    23
%     19    20    35    28    17    14
%     23    17    31    22    22    18
%     26    16    16    16    37    22
%     23    22    19    18    22    28

%% All trials (takes slightly longer)

MCR.Classification.crossValidateMulti(X, labels6, 'classifier', 'lda')
ans.CM
% ans =
% 
%    413    38    84   111   108   110
%     46   666    30    23    36    63
%    108    22   445   129    83    77
%    113    48   110   431    85    77
%     98    48    82    87   370   179
%    112    53    82    62   174   381

%% Only 300 trials total

xUse = X(:, :, 1:300);
yUse = labels6(1:300);
MCR.Classification.crossValidateMulti(xUse, yUse, 'classifier', 'lda')
ans.CM
% ans =
% 
%     12     4     4     4    13    12
%      6    15     8     6     7     9
%      9     7    10    12    10     4
%      3    14    12    11     4     6
%      4    11     6     7    12     8
%     11     5     7     9    15     3

%% 299 trials total (ensuring slight unbalance)
xUse = X(:, :, 1:299);
yUse = labels6(1:299);
MCR.Classification.crossValidateMulti(xUse, yUse, 'classifier', 'lda')
ans.CM
% ans =
% 
%     12     5     7     6    10     9
%      5    15     9     6     7     9
%      7     6     9    13     9     8
%      4    12    12    10     6     6
%      4    12     9     8     8     7
%      9    12     4     7    10     7
%% Average the trials in advance (takes slightly longer)
[xAvg, yAvg] = MCR.Preprocessing.averageTrials(X, labels6, 7, 'randomseed', 0);
MCR.Classification.crossValidateMulti(xAvg, yAvg, 'classifier', 'LDA')
ans.CM
% ans =
% 
%    106     0     4     3     4     6
%      1   114     0     1     1     6
%      4     0   101     7     8     3
%      7     0    10   100     3     3
%      7     1     2     7    79    27
%      7     3     4     3    22    84