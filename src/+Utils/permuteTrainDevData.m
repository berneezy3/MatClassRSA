function [ptrainX, pDevData, pTrainLabels, pDevLabels] = permuteTrainDevData(trainX, testX, trainY, testY)
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