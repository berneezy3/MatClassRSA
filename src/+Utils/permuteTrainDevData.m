function [ptrainX, pDevData, pTrainLabels, pDevLabels] = permuteTrainDevData(trainX, testX, trainY, testY)
% [ptrainX, pDevData, pTrainLabels, pDevLabels] = permuteTrainDevData(... 
% trainX, testX, trainY, testY)
% ------------------------------------------------------------------------
% permuteTrainDevData randomly shuffles the labels across the combined
% training and test sets and then reassigns them into permuted training and
% test (development) labels.
%
%   Inputs:
%       trainX   - Training feature matrix.
%       testX    - Test (or development) feature matrix.
%       trainY   - Training labels (vector or matrix with one label per sample).
%       testY    - Test labels.
%
%   Outputs:
%       ptrainX      - Same as trainX (features remain unchanged).
%       pDevData     - Same as testX.
%       pTrainLabels - Permuted training labels.
%       pDevLabels   - Permuted test (development) labels.

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

    % Determine the number of training and test samples.
    nTrain = size(trainY, 1);
    nTest  = size(testY, 1);

    % Combine the labels from the training and test sets.
    combinedLabels = [trainY; testY];

    % Generate a random permutation of indices.
    permIndices = randperm(length(combinedLabels));

    % Apply the permutation.
    permutedLabels = combinedLabels(permIndices);

    % Split the permuted labels back into training and test parts.
    pTrainLabels = permutedLabels(1:nTrain, :);
    pDevLabels   = permutedLabels(nTrain+1:end, :);

    % The features remain unchanged.
    ptrainX  = trainX;
    pDevData = testX;
end