% example_Reliability_computeSampleSizeReliability.m
% --------------------------------------------------
% Example function calls for computeSampleSizeReliability() function within
% the +Reliability module
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

clear all; close all; clc

rngSeed = 3;

load('S01.mat');


%% 3D input, RNG set by timestamp, featureIndx: temporal sample index

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15);
%% 2D input, RNG set by timestamp, featureIndx: temporal sample index

X2D = squeeze(X(96,:,:))'; % 3D (electrode x time x trial) -> single electrode 2D (trial x time)
reliabilities = Reliability.computeSampleSizeReliability(X2D, labels72, 15);
%% Reproducible RNG, Single-Argument

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'});
%% Number of Trials Per Split-half

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'numTrialsPerHalf', 20);
%% Number of Permutations Splitting Trials for Split-Half Reliability (Not Displayed)

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'}, 'numTrialsPerHalf', 20, 'numPermutations', 20);
%% Number of Permutations Choosing Trials (Displayed)

reliabilities = Reliability.computeSampleSizeReliability(X, labels72, 15, 'rngType', {rngSeed,'philox'}, 'numTrialsPerHalf', 20, 'numPermutations', 20, 'numTrialPermutations', 20);