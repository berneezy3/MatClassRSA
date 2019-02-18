function [C, varargout] = classifyPredict(M, X, varargin)
% -------------------------------------------------------------------------
% [CM, accuracy, classifierInfo] = classifyPredict(X, Y, shuffleData)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for fitting data to create a model.  
%
% INPUT ARGS (REQUIRED)
%   X - training data
%   Y - labels
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'timeUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the time dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       time dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'spaceUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the space dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       space dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'featureUse' - If X is a 2D, trials-by-features matrix, then this
%       option will subset X along the features dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       feature dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 3D,
%       space-by-time-by-trials matrix.
%   'randomSeed' - This option determines whether the randomization is to produce
%       varying or unvarying results each different execution.
%        --options--
%       'shuffle' (default)
%       'default' (replicate results)
%   'shuffleData' - determine whether to shuffle the order of trials within 
%       training data matrix X (order of labels in the labels vector Y will be
%       shuffled in the same order)
%       --options--
%       1 - shuffle (default)
%       0 - do not shuffle
%   'averageTrials' - how to compute averaging of trials in X to increase accuracy
%       --options--
%       (negative value) - don't average
%       (postitive int) - number of integers to average over
%   'averageTrialsHandleRemainder' - Handle remainder trials (if any) from 
%       trial averaging 
%       --options--
%
%
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 90% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       features of input matrix X.
%   'PCAinFold' - whether or not to conduct PCA in each fold.
%       --options--
%       1 (default) - conduct PCA within each fold.
%       0 - one PCA for entire training data matrix X.
%   'nFolds' - number of folds in cross validation.  Must be integer
%       greater than 1 and less than number of trials. Default is 10.
%   'classify' - choose classifier. 
%        --options--
%       'SVM' (default)
%       'LDA' 
%       'RF' 
%   pValueMethod - Choose the method to compute p-value.  
%       --options--
%       'binomcdf' (default)
%           computes a binomial cdf at each of the values in x using number 
%           of permutations sepcified in 'permutations'in N and probability 
%           of success for each trial in p
%       'permuteTestLabels' 
%           with the 'permuteTestLabels' option, we perform k -fold cross 
%           validation only once. In each fold, the classification model is   
%           trained on the intact data and labels, but predictions are made
%           on test observations whose labels have been shuffled. The prediction   
%           is repeated N times, with the test labels re-randomized for each   
%           attempt. The 'permuteTestLabels' option is the second fastest method,   
%           since it requires training the k models only once, but a total of
%           k * N  prediction operations are performed. So that there are enough
%           test labels to randomize in each fold, here we also recommend having   
%           at least 100 observations total, and no more than 10 cross-validation folds.
%       'permuteFullModel'
%           With the ?permuteFullModel? option, we perform the entire 10-fold 
%           cross validation N times. For each of the N permutation iterations, 
%           the entire labels vector (training and test observations) is shuffled, 
%           and in each fold, the classifier model is both trained and tested using 
%           the shuffled labels. As the full classification procedure is performed 
%           N times, the ?permuteFullModel? option is the slowest, but is suitable 
%           to use with any classifier configuration, including settings with 
%           unbalanced classes, few observations, and up to N-fold cross validation.
%   'permutations' - Choose number of permutations to perform.  Default
%           1000.  This option will only work if 'permuteFullModel' or 
%           'permuteTestLabels' is chosen.
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'polynomial' 
%       'rbf' (default)
%       'sigmoid' 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the inimum number of observations per tree leaf.
%   Default is 1,
%   'verbose' - Include the distribution of accuracies from the
%   permutations test and also a concatednated struct of all the models
%
% OUTPUT ARGS 
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
%   accuracy - Classification accuracy
%   predY - predicted label vector
%   pVal - p-value of the classification
%   classifierInfo - A struct summarizing the options selected for the
%       classification.
%   accDist (verbose output) - The distribution of N accuracies
%       calculated from the permutation test in vector form.  This argument will be 
%       NaN is 'binomcdf' is passed into parameter 'pValueMethod', or else,
%       it will return the accuracy vector.
%   modelsConcat (verbose output) - Struct containing the N models used during cross
%   validation.
%

% TODO:
%   Check when the folds = 1, what we should do 

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


    % Predict Labels for Test Data
    predY = modelPredict(testData, mdl);
    
    % Get Confusion Matrix
    CM = confusionmat(testLabels, predY);
    
    % Get Accuracy
    accuracy = computeAccuracy(predY, testLabels); 
    
    % Get p-Value
    %pVal = pbinom(Y, ip.Results.nFolds, accuracy);
    pVal = pbinomNoXVal( testLabels, accuracy, length(unique(trainLabels)));
    



end