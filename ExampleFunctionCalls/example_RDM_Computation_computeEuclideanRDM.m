% example_RDM_Computation_computeEuclideanRDM.m
% ---------------------------------------------
% Example function calls for computeEuclideanRDM() function within
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

singleElectrodeX = squeeze(X(96,:,:));
singleTimePointX = squeeze(X(:,11,:));

%% Single Electrode, RNG set by timestamp,

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72);
%% Single Time Point , RNG set by timestamp

D = RDM_Computation.computeEuclideanRDM(singleTimePointX, labels72);
%% Reproducible RNG, Single-Argument

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', {rngSeed,'philox'});
%% Number of Permutations

D = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels72, 'rngType', {rngSeed,'philox'}, 'numPermutations', 20);

