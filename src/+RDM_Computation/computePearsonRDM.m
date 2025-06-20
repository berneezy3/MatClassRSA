function D = computePearsonRDM(X, Y, varargin)
%----------------------------------------------------------------------------------
%  D = ...
%  RDM_Computation.computePearsonRDM(X, Y, numPermutations, rngType)
%----------------------------------------------------------------------------------
%
% This function returns pairwise dissimilarities with respect to cross-validated Pearson
% correlation.  A possible data input to this function would have dimensions:
% nElectrodes x (nTrials*nClasses).  With this input, the resulting RDM would be
% computed using the electrode values at a specific time point as features.  On
% the other hand, one could also provide, as input, data of dimensions:
% nTimepoints x (nTrials*nClasses).  In this case, the resulting RDM would be
% computed using the time point values for a particular electrode as features.
%
% REQUIRED INPUTS:
%   X - data matrix. The size of X should be nFeatures x
%              (nTrials*nClasses)
%   Y - labels vector. The size of Y should be (nTrials*nClasses)
%
% OPTIONAL NAME-VALUE INPUTS:
%   numPermutations - how many permutations to randomly select
%       train and test data matrix. If not entered or empty, this defaults 
%       to 10.
%   rngType - Random number generator specification. Here you can set the
%       the rng seed and the rng generator, in the form {'rngSeed','rngGen'}.
%       If rngType is not entered, or is empty, rng will be assigned as 
%       rngSeed: 'shuffle', rngGen: 'twister'. Where 'shuffle' generates a 
%       seed based on the current time.
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
%   D - output struct object containing computed Pearson RDM 
%        across all perumtations, and average RDM
%   --subfields--
%   RDM - The average Pearson RDM across all user-specified
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


num_dim = length(size(X));
assert(num_dim == 2, 'Data of this size are not supported. A typical use case would be to provide a 2D matrix with dimensions of: nSpace-by-nTrials.');
assert(size(X,2) == length(Y), 'Mismatch in number of trials in data and length of labels vector.');


% Set random number generator
if any(strcmp(ip.UsingDefaults, 'rngType')), Utils.setUserSpecifiedRng();
else, Utils.setUserSpecifiedRng(ip.Results.rngType);
end

% Input data are usable: Print size of input variables.
disp(['<a href="matlab: open(which(''computeEuclideanRDM.m''))">computePearsonRDM</a> input feature-by-trial data matrix is of size ' mat2str(size(X)) '.'])
disp(['<a href="matlab: open(which(''computeEuclideanRDM.m''))">computePearsonRDM</a> input labels vector is of length ' num2str(length(Y)) '.'])


unique_labels = unique(Y);
num_images = length(unique_labels);
num_features = size(X,1);
dissimilarities = zeros(ip.Results.numPermutations, num_images, num_images);
for p=1:ip.Results.numPermutations
    
    for i=1:num_images
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
        
        for j=i+1:num_images
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
            
            cvPear = computeCvPearson(img1_train, img1_test, img2_train, img2_test);
            dissimilarities(p,i,j) = cvPear;
            dissimilarities(p,j,i) = cvPear;
            
        end % second image
    end % first image
end % permutations

%  Permute so that the dimensions are: nLabels x nLabels x nPerms
dissimilarities = permute(dissimilarities, [2,3,1]);

% Populate output struct
D.dissimilarities = dissimilarities;
D.RDM = mean(dissimilarities, 3);

end % function


function [cvPearsonVal] = computeCvPearson(img1train, img1test, img2train, img2test)
% Arguments are all vectors
% Return 1 - pearson

var_img1_train = var(img1train);
var_img2_train = var(img2train);
denom_noncv = sqrt(var_img1_train * var_img2_train);
cov_train1test2 = getfield(cov(img1train, img2test), {2});
cov_train2test1 = getfield(cov(img2train, img1test), {2});
cov_12 = (cov_train1test2 + cov_train2test1) / 2;

var_traintest1 = getfield(cov(img1train, img1test), {2});
var_traintest2 = getfield(cov(img2train, img2test), {2});

regularize_var = 0.1;
regularize_denom = 0.25;

denom = sqrt(max(regularize_var * var_img1_train, var_traintest1) * max(regularize_var * var_img2_train, var_traintest2));
denom = max(regularize_denom * denom_noncv, denom);

cvPearsonVal = cov_12 / denom;
cvPearsonVal = min(max(-1, cvPearsonVal), 1);
cvPearsonVal = 1 - cvPearsonVal;

end


