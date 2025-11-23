% example_RDM_Computation_shiftPairwiseAccuracy.m
% -----------------------------------------------
% Example function calls for shiftPairwiseAccuracy() function within
% the +RDM_Computation module
%
% This example requires one or more example data files. Run the 
% illustrative_0_downloadExampleData script in the IllustrativeAnalyses 
% folder if you have not already downloaded the example data. 

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

clear all; close all; clc;

load('S01.mat');
rngSeed = 3;

% Preprocessing steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% SVM classifiction hyperparameters
gamma_opt = 1.0000e-5;
C_opt = 100000;

M = Classification.crossValidatePairs(xAvg, yAvg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

% Moving forward with this pairwise accuracies
pairAcc = M.AM;

%% Basic Function Call with Pairwise Accuracy Matrix

RDM = RDM_Computation.shiftPairwiseAccuracyRDM(pairAcc);
RDM

%% Shift Accuracies on 1-100 scale, 'pairScale' 100

scaledAcc = pairAcc*100;

RDM = RDM_Computation.shiftPairwiseAccuracyRDM(scaledAcc, 'pairScale', 100);
RDM


