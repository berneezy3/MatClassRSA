 function M = trainPairs(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% C = RSA.classify.trainPairs(X, Y, varargin)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for cross-validating data.  
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
%   'randomSeed' - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister').
%       --- Acceptable specifications for rand_seed ---
%       - Single acceptable rng specification input (e.g., 1,
%           'default', 'shuffle'); in these cases, the generator will
%           be set to 'twister'.
%       - Dual-argument specifications as either a 2-element cell
%           array (e.g., {'shuffle', 'twister'}) or string array
%       (   e.g., ["shuffle", "twister"].
%       - rng struct as assigned by rand_seed = rng.
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 99% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       0 - PCA turned off
%       features of input matrix X.
%        --options--
%       'SVM' 
%       'LDA' (default)
%       'RF' 
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' (default)
%       'polynomial' 
%       'rbf' 
%       'sigmoid' 
%   'gamma' - 
%   'C' - 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the minimum number of observations per tree leaf.
%   Default is 1,
%   'permutations' - Choose number of permutations to perform. Default value 
%   is 0, where permutation testing is turned off.  
%   'center' - Specification for centering columns of the data.  If empty or 
%   not specified, will default to true.
%   'scale' - Specification for scaling columns of the data. If
%   empty or not specified, will default to true.
%
%
% OUTPUT ARGS 
%   C - output object containing all cross validation related
%   information, including confucion matrix, accuracy, prediction results
%   etc.  The structure of C will differ depending on the value of the 
%   input value 'pairwise', which is set to 0 by default.  if 'pairwise' 
%   is set to 1, then C will be a cell matrix of structs, symmetrical along 
%   the diagonal.  If pairwise is 0, then C is a struct containing values:
%   
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
%   accuracy - Classification accuracy
%   predY - predicted label vector
%   modelsConcat - Struct containing the N models used during cross
%   validation.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO : FINISH DOCSTRING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    %Required inputs
    ip = initInputParser(namestr, ip);
    parse(ip, X, Y, varargin{:});

    [r c] = size(X);
            
    % Initilize info struct
    classifierInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'classifier', ip.Results.classifier);

    % throw error on missing data
    if (find(isnan(X(:))))
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end

    
   % check if data is double, convert to double if it isn't
   [X, Y] = convert2double(X, Y);

   
   [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                ip.Results.spaceUse, ...
                                                ip.Results.timeUse, ...
                                                ip.Results.featureUse);

    
    % let r and c store size of 2D matrix
    [r c] = size(X);
    [r1 c1] = size(Y);
    
    if (r1 < c1)
        Y = Y';
    end
    

    %%%%% Whatever we started with, we now have a 2D trials-by-feature matrix
    % moving forward.
    
    
    % Split data into pairs representing each combination of labels  
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = initPairwiseCellMat(numClasses);
    
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses, 2);
    M = struct();
    RSA = MatClassRSA;

    % PAIRWISE LDA/RF
    if (strcmp(upper(ip.Results.classifier), 'LDA') || ...
        strcmp(upper(ip.Results.classifier), 'RF') || ...
        strcmp(upper(ip.Results.classifier), 'SVM') && ip.Results.PCA >0)
    
    j = 0;
    
    M.pairwise = 1;
    M.classifier = ip.Results.classifier;
    
    % since we are returning multiple classification, we initialize the 
    % return format to be cell array to hold multiple structs
    M.mdl = {};
    M.classifierInfo = {};
    M.scale = {};
    
    for cat1 = 1:numClasses-1
        for cat2 = (cat1+1):numClasses
            j = j+1;
            disp([num2str(cat1) ' vs ' num2str(cat2)]) 
            currUse = ismember(Y, [cat1 cat2]);

            tempX = X(currUse, :);
            tempY = Y(currUse);
            % Store the accuracy in the accMatrix
            [~, tempM] = evalc([' RSA.classify.trainMulti(tempX, tempY, ' ...
                ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
                ' ''kernel'', ip.Results.kernel,'...
                ' ''gamma'', ip.Results.gamma, ' ...
                ' ''C'', ip.Results.C, ' ... 
                ' ''numTrees'', ip.Results.numTrees, ' ...
                ' ''minLeafSize'', ip.Results.minLeafSize, '...
                ' ''center'', ip.Results.center, ' ...
                ' ''scale'', ip.Results.scale, ' ...
                ' ''randomSeed'', ''default'' ) ' ]);
            tempM.classifierInfo.numClasses = numClasses;
            M.classifierInfo{j} =  tempM.classifierInfo;
            M.mdl{j} = tempM.mdl;
            M.scale{j} = tempM.scale;
        end
    end
    % END PAIRWISE LDA/RF
    % START SVM skipping the pairwise split to decrease runtime
    elseif  strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA <= 0)
        

        [mdl, scale] = fitModel(X, Y, ip, ip.Results.gamma, ip.Results.C);

        [~, tempM] = evalc([' RSA.classify.trainMulti(X, Y, ' ...
            ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
            ' ''kernel'', ip.Results.kernel,'...
            ' ''gamma'', ip.Results.gamma, ' ...
            ' ''C'', ip.Results.C, ' ... 
            ' ''numTrees'', ip.Results.numTrees, ' ...
            ' ''minLeafSize'', ip.Results.minLeafSize, '...
            ' ''center'', ip.Results.center, ' ...
            ' ''scale'', ip.Results.scale, ' ...
            ' ''randomSeed'', ''default'' ) ' ]);
        
        tempM.classifierInfo.pairwise = 1;
        M = tempM;
        
        M.pairwise = 1;
        M.classifier = ip.Results.classifier;

    end
 end

 
 