function [M, varargout] = trainMulti_opt(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% C = trainMulti_opt(X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% Train a model given test data and labels, with classifier hyperparameter
% optimization
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
%           (e.g., ["shuffle", "twister"].
% - rng struct as assigned by rand_seed = rng.
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 99% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       features of input matrix X.
%       (negative value) - off
%       features of input matrix X.
%   'classifier' - choose classifier. 
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
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the inimum number of observations per tree leaf.
%   Default is 1,
%   'pairwise' - When set to 1, this creates models for pairwise 
%   classification (one vs. one).  This returns n choose 2 number of 
%   decision boundaries.  When using classify predict, this returns a
%   prediction for each decision boundary.  Set to 0 to turn off.  This 
%   parameter does not need to be passed to classifyPredict(). 
%   'center' - Specification for centering columns of the data.  If empty or 
%   not specified, will default to true.
%   'scale' - Specification for scaling columns of the data. If
%   empty or not specified, will default to true.
%   'gammaSpace' - Set vector of gamma values to search over for the SVM rbf
%   kernel
%   'CSpace' - Set vector of C values to search over for the SVM rbf kernel
%
% OUTPUT ARGS 
%   M - Classification output.  This outer struct contains two inner 
%   structs: M.mdl, which contains the model, and M.classifierInfo. which 
%   contains classifier related info.  Must pass M to classifyPredict() to
%   predict new data.
%   
%   When 'pairwise' is set to 1, then this may return a length n choose 2
%   cell array of structs, each one containing a classification struct M
%   foreach decision boundary.  

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

    tic
    
    %initialize output struct C
    C = struct;
    
    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;
    st = dbstack;
    namestr = st.name;
    ip = initInputParser(namestr, ip);

    % ADD SPACEUSE TIMEUSE AND FEATUREUSE, DEAFULT SHOULD B EMPTY MATRIX
    
    [r c] = size(X);

    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.

    % Parse
    try 
        parse(ip, X, Y, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
    
    
    
    % check input data 
    checkInputData(X, Y);
    dataSize = size(X);
    if(ip.Results.spaceUse)
        dataSize(1) = length(ip.Results.spaceUse);
    end
    if(ip.Results.timeUse)
        dataSize(2) = length(ip.Results.timeUse);
    end
    if(ip.Results.featureUse)
        dataSize(2) = length(ip.Results.featureUse);
    end

    
    % this function contains input checking functions
    [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                    ip.Results.spaceUse, ...
                                                    ip.Results.timeUse, ...
                                                    ip.Results.featureUse);
    
                                           
                                     
                     
    defaultShuffleData = 1;
    defaultRandomSeed = 'shuffle';
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';

    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    %rng(ip.Results.randomSeed);
    setUserSpecifiedRng(ip.Results.randomSeed);

    % Moving centering and scaling parameters out of ip, in case we need to
    % override the user's centering specification
    ipCenter = ip.Results.center; 
    ipScale = ip.Results.scale;
    if ((~ip.Results.center) && (ip.Results.PCA>0) ) 
        warning(['Data centering must be on if performing PCA. Overriding '...
        'user input and removing the mean from each data feature.']);
        ipCenter = true;
    end
    
    trainData = X;
    
    % PCA
    if (ip.Results.PCA > 0)
        disp('Conducting Principal Component Analysis...')
        % accordingly center and scale test data
        [trainData, colMeans, colScales] = centerAndScaleData(trainData, ...
            ipCenter, ipScale);
        [trainData, V, nPC] = getPCs(trainData, ip.Results.PCA);
    else 
        disp('Principal Component Analysis turned off')
        V = NaN;
        nPC = NaN;
        colMeans = NaN;
        colScales = NaN;
    end
    
    % Train Model
    disp('Training Model...')
    
    % create classifier info struct
    classifierInfo = struct();
    classifierInfo.PCA = ip.Results.PCA;
    classifierInfo.classifier = ip.Results.classifier;
    classifierInfo.spaceUse = ip.Results.spaceUse;
    classifierInfo.timeUse = ip.Results.timeUse;
    classifierInfo.featureUse = ip.Results.featureUse; %'shuffleData', ip.Results.shuffleData, ...
    classifierInfo.randomSeed = ip.Results.randomSeed;
    classifierInfo.PCA_V = V;
    classifierInfo.PCA_nPC = nPC;
    classifierInfo.trainingDataSize = dataSize;
    classifierInfo.numClasses = length(unique(Y));
    classifierInfo.pairwise = ip.Results.pairwise;
    classifierInfo.colMeans = colMeans;
    classifierInfo.colScales = colScales;
    
    switch classifierInfo.classifier
        case 'SVM'
            classifierInfo.kernel = ip.Results.kernel;
        case 'LDA'
        case 'RF'
            classifierInfo.numTrees = ip.Results.numTrees;
            classifierInfo.minLeafSize =  ip.Results.minLeafSize;
    end
    
    if(ip.Results.pairwise == 0) 
        disp('Conducting multiclass classification.  Pairwise turned off');
    else 
        disp('Conducting pairwise classification.  Multiclass turned off');
    end
    
    disp(['classifying with ' ip.Results.classifier] )
    
    
%     if (ip.Results.pairwise == 0) || ...
%        ((ip.Results.pairwise == 1) && strcmp(ip.Results.classifier, 'SVM'))
        
        % conduct grid search here
        [gamma_opt, C_opt] = gridSearchSVM(trainData, Y(:), ...
            ip.Results.gammaSpace, ip.Results.cSpace, ip.Results.kernel);
        [mdl, scale] = fitModel(trainData, Y(:), ip, gamma_opt, C_opt);
        M.classifierInfo = classifierInfo;
        M.mdl = mdl;
        M.scale = scale;
        M.pairwise = 0;
        M.classifier = ip.Results.classifier;


    
    
    disp('Training Finished...')
    disp('Returning Model')

    toc    
    return;

end