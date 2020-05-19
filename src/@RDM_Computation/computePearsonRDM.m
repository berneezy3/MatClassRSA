function [dissimilarities] = computePearsonRDM(obj,X, Y, num_permutations, rand_seed)
%----------------------------------------------------------------------------------
%  RSA = MatClassRSA;
%  [dissimilarities] = ...
%  RSA.computeRDM.computePearsonRDM(X, Y, num_permutations, rand_seed)
%----------------------------------------------------------------------------------
%
% Returns pairwise dissimilarities with respect to cross-validated Pearson
% correlation.  A possible data input to this function would have dimensions:
% nElectrodes x (nTrials*nImages).  With this input, the resulting RDM would be
% computed using the electrode values at a specific time point as features.  On
% the other hand, one could also provide, as input, data of dimensions:
% nTimepoints x (nTrials*nImages).  In this case, the resulting RDM would be
% computed using the time point values for a particular electrode as features.
%
% Input Args:
%   X - data matrix. The size of X should be nFeatures x
%              (nTrials*nImages)
%   Y - labels vector. The size of Y should be (nTrials*nImages)
%   num_permutations (optional) - how many permutations to randomly select
%                                 train and test data matrix.
%   rand_seed (optional) - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister').
%       --- Acceptable specifications for rand_seed ---
%           - Single acceptable rng specification input (e.g., 1,
%               'default', 'shuffle'); in these cases, the generator will
%               be set to 'twister'.
%           - Dual-argument specifications as either a 2-element cell
%               array (e.g., {'shuffle', 'twister'}) or string array
%               (e.g., ["shuffle", "twister"].
%           - rng struct as assigned by rand_seed = rng.
%
% Output Args:
%   dissimilarities - the dissimilarity matrix, dimensions: num_images
%                     x num_images x num_permutations

num_dim = length(size(X));
assert(num_dim == 2, 'Data of this size are not supported. A typical use case would be to provide a 2D matrix with dimensions of: nSpace-by-nTrials.');
assert(size(X,2) == length(Y), 'Mismatch in number of trials in data and length of labels vector.');

if nargin < 3 || isempty(num_permutations)
    num_permutations = 10;
end

% Set random number generator
if nargin < 4 || isempty(rand_seed), setUserSpecifiedRng();
else, setUserSpecifiedRng(rand_seed);
end

unique_labels = unique(Y);
num_images = length(unique_labels);
num_features = size(X,1);
dissimilarities = zeros(num_permutations, num_images, num_images);
for p=1:num_permutations
    
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


