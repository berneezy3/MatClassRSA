% example_Preprocessing_shuffleData.m
% -----------------------------------
% Example function calls for shuffleData() function within
% the +Preprocessing module

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
nTrial = 1000;
nSpace = 10;
nTime = 20;
nCatagories = 10;
nParticipants = 3;

X_3D = rand(nSpace, nTime, nTrial);
X_2D = rand(nTrial, nTime);
P = randi(nParticipants, [1 nTrial]);
Y = randi(nCatagories, [1 nTrial]);

%% 3D input, RNG set by timestamp

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y);
%% 2D input, RNG set by timestamp

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_2D, Y);
%% Reproducible RNG, Single-Argument

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, 'rngType', rngSeed);
%% Reproducible RNG, Double-Argument

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, 'rngType', {rngSeed,'philox'});
%% Participant vector

[randX, randY, randP, randIdx] = Preprocessing.shuffleData(X_3D, Y, P);
