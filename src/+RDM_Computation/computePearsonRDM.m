function [dissimilarities] = computePearsonRDM(X, Y, varargin)
%----------------------------------------------------------------------------------
%  RSA = MatClassRSA;
%  [dissimilarities] = ...
%  RSA.computeRDM.computePearsonRDM(X, Y, num_permutations, rngType)
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
% Input Args (REQUIRED):
%   X - data matrix. The size of X should be nFeatures x
%              (nTrials*nImages)
%   Y - labels vector. The size of Y should be (nTrials*nImages)
%
% Input Args (OPTIONAL NAME-VALUE PAIRS):
%   num_permutations (optional) - how many permutations to randomly select
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
% Output Args:
%   dissimilarities - the dissimilarity matrix, dimensions: num_images
%                     x num_images x num_permutations


% parse inputs
ip = inputParser;
addRequired(ip, 'X');
addRequired(ip, 'Y');
addParameter(ip, 'num_permutations', 10);
addParameter(ip, 'rngType', 'default');
parse(ip, X, Y, varargin{:})


num_dim = length(size(X));
assert(num_dim == 2, 'Data of this size are not supported. A typical use case would be to provide a 2D matrix with dimensions of: nSpace-by-nTrials.');
assert(size(X,2) == length(Y), 'Mismatch in number of trials in data and length of labels vector.');


% Set random number generator
if any(strcmp(ip.UsingDefaults, 'rngType')), setUserSpecifiedRng();
else, setUserSpecifiedRng(ip.Results.rngType);
end

unique_labels = unique(Y);
num_images = length(unique_labels);
num_features = size(X,1);
dissimilarities = zeros(ip.Results.num_permutations, num_images, num_images);
for p=1:ip.Results.num_permutations
    
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


