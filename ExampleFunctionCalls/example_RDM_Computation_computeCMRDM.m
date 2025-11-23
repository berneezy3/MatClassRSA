% example_RDM_Computation_computeCMRDM.m
% --------------------------------------
% Example function calls for computeCMRDM() function within
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

M = Classification.crossValidateMulti(xAvg, yAvg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

% Moving forward with this confusion matrix
confMatrix = M.CM;

%% Basic Function Call with Confusion Matrix

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix);
RDM

%% Normalization by 'sum'
% default normalization set to 'sum'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'sum');
RDM

%% Normalization by 'diagonal'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'diagonal');
RDM

%% No normalization

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'none');
RDM

%% Symmetrizing with 'arithmetic' mean
% default symmetrization set to 'arithmetic'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'arithmetic');
RDM

%% Symmetrizing with 'geometric' mean

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'geometric');
RDM

%% Symmetrizing with 'harmonic' mean

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'harmonic');
RDM

%% No symmetrization

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'none');
RDM

%% Linear distance transformation
% default distance transformation set to 'linear'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'linear');
RDM

%% Power distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'power', 'distpower', 2);
RDM


%% Logarithmic distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'logarithmic', 'distpower', 2);
RDM

%% No distance transformation

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'distance', 'none');
RDM

%% Rank distances with 'rank'
% default set to 'none'

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'rank');
RDM

%% Percentile rank distances

[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'percentrank');
RDM

%% No ranking of distances
% this is default
[RDM, params] = RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'none');
RDM

