function D = computeEuclideanRDM(X, Y, varargin)
%------------------------------------------------------------------------------------
%  D = ...
%  RDM_Computation.computeEuclideanRDM(X, Y, numPermutations, rngType)
%------------------------------------------------------------------------------------
%
% This function returns pairwise similarities with respect to cross-
% validated Euclidean distance.  A possible data input to this function 
% would have dimensions: nElectrodes x (nTrials*nClasses).  With this 
% input, the resulting RDM would be computed using the electrode values at 
% a specific time point as features.  On the other hand, one could also 
% provide, as input, data of dimensions: nTimepoints x (nTrials*nClasses).  
% In this case, the resulting RDM would be computed using the time point 
% values for a particular electrode as features.
%
% REQUIRED INPUTS:
%   X - data matrix. The size of X should be nFeatures x nTrials. Users 
%       working with 3D data matrices should already have subset the data 
%       along a single sensor (along the space dimension) or time sample 
%       (along the time dimension).
%   Y - labels vector. The length of Y should be nTrials.
%
% OPTIONAL NAME-VALUE INPUTS:
%   numPermutations - how many permutations to randomly select
%       train and test data matrix. If not entered or empty, this defaults 
%       to 10.
%   rngType - Random number generator specification, for reproducibility. 
%       Here you can set the the rng seed and the rng generator, in the form 
%       {'rngSeed','rngGen'}.If rngType is not entered, or is empty, rng will 
%       be assigned as rngSeed: 'shuffle', rngGen: 'twister'. Where 'shuffle' 
%       generates a seed based on the current time.
%       --- Acceptable specifications for rngType ---
%           - Single-argument specification, sets only the rng seed
%               (e.g., 4, 0, 'shuffle'); in these cases, the rng generator  
%               will be set to 'twister'. If a number is entered, this number will 
%               be set as the seed. If 'shuffle' is entered, the seed will be 
%               based on the current time.
%           - Dual-argument specifications as either a 2-element cell 
%               array (e.g., {'shuffle', 'twister'}, {6, 'twister'}) or string array 
%               (e.g., ["shuffle", "philox"]). The first argument sets the
%               The first argument set the rng seed. The second argument
%               sets the generator to the specified rng generator type.
%           - rng struct as previously assigned by rngType = rng.
%
% OUTPUTS:
%   D - output struct object containing computed Euclidean RDM 
%        across all perumtations, and average RDM
%   --subfields--
%   RDM - The average Euclidean RDM across all user-specified
%           permutations. Size is nClasses x nClasses.
%   dissimilarities - All computed dissimilarities across all permutations
%           with the size nClasses x nClasses x nPermutations.
%
% This code was adapted from a code tutorial provided by Guggenmos et al.
% (2018):
% - https://github.com/m-guggenmos/megmvpa/blob/master/tutorial_matlab/matlab_distance.ipynb
% - Related publication: Guggenmos, M., Sterzer, P., & Cichy, R. M. (2018). 
%   Multivariate pattern analysis for MEG: A comparison of dissimilarity 
%   measures. Neuroimage, 173, 434-447. DOI: 10.1016/j.neuroimage.2018.02.044
%
% MatClassRSA dependencies: Utils.setUserSpecifiedRng()

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

% parse inputs
ip = inputParser;
addRequired(ip, 'X');
addRequired(ip, 'Y');
addParameter(ip, 'numPermutations', 10);
addParameter(ip, 'rngType', 'default');
parse(ip, X, Y, varargin{:})

if nargin < 2
    error('At least two inputs are required: A 2D data matrix and a labels vector.');
end

% Input data needs to be a 2D matrix
num_dim = length(size(X));
assert(num_dim == 2, 'Input data must be a 2D matrix. A typical use case would be to provide a 2D matrix with dimensions of: nSpace-by-nTrials.');

% The size of dimension 2 of the input matrix X should be length nTrials.
try
    assert(size(X,2) == length(Y));

% If it's not, we'll attempt to correct by transposing X.
catch
    X = transpose(X);
    assert(size(X,2) == length(Y), ['Mismatch in number of trials in data and length of labels vector. 2D input matrix should be feature x trial.']);
    warning('computeEuclideanRDM:transposeInput',... 
        '<a href="matlab: open(which(''computeEuclideanRDM.m''))">computeEuclideanRDM</a> line 50. Input data matrix has been transposed in order for column dimension to match length of labels vector.')
end

% Input data are usable: Print size of input variables.
disp(['<a href="matlab: open(which(''computeEuclideanRDM.m''))">computeEuclideanRDM</a> input feature-by-trial data matrix is of size ' mat2str(size(X)) '.'])
disp(['<a href="matlab: open(which(''computeEuclideanRDM.m''))">computeEuclideanRDM</a> input labels vector is of length ' num2str(length(Y)) '.'])

% Set random number generator
if any(strcmp(ip.UsingDefaults, 'rngType')), Utils.setUserSpecifiedRng();
else, Utils.setUserSpecifiedRng(ip.Results.rngType);
end

unique_labels = unique(Y);
num_labels = length(unique_labels);
num_features = size(X,1);
dissimilarities = zeros(ip.Results.numPermutations, num_labels, num_labels);
for p=1:ip.Results.numPermutations
    
    for i=1:num_labels
        curr_label_i = unique_labels(i);
        
        img1_data = squeeze(X(:,Y==curr_label_i));
        % Split trials into two partitions (i.e. train/test)
        img1_trials = size(img1_data, 2);
        % Randomly permute data
        img1_data = img1_data(:,randperm(img1_trials));
        % Split into train/test
        img1_train = img1_data(:,1:floor(img1_trials/2));
        img1_test = img1_data(:,floor(img1_trials/2)+1:img1_trials);
        % Compute mean across the trials
        img1_train = squeeze(mean(img1_train,2));
        img1_test = squeeze(mean(img1_test,2));
        
        for j=i+1:num_labels
            curr_label_j = unique_labels(j);
            
            img2_data = squeeze(X(:,Y==curr_label_j));
            % Split trials into two partitions (i.e. train/test)
            img2_trials = size(img2_data, 2);
            % Randomly permute data
            img2_data = img2_data(:,randperm(img2_trials));
            % Split into train/test
            img2_train = img2_data(:,1:floor(img2_trials/2));
            img2_test = img2_data(:,floor(img2_trials/2)+1:img2_trials);
            % Compute mean across the trials
            img2_train = squeeze(mean(img2_train,2));
            img2_test = squeeze(mean(img2_test,2));
            
            % Compute cv-Euclidean distance (x-y)'(x-y)
            cvEd = dot((img1_train - img2_train), (img1_test - img2_test));
            % Record value
            dissimilarities(p,i,j) = cvEd;
            dissimilarities(p,j,i) = cvEd;
            
        end % second image
    end % first image
end % permutations

%  Permute so that the dimensions are: nLabels x nLabels x nPerms
dissimilarities = permute(dissimilarities, [2,3,1]);

% Populate output struct
D.dissimilarities = dissimilarities;
D.RDM = mean(dissimilarities, 3);

end % function


