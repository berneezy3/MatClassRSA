function [dissimilarities] = cvEuclidean(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
%  [dissimilarities] = cvEuclidean(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
% Nathan Kong
%
% Returns pairwise similarities with respect to cross-validated
% Pearson correlation.
% Input Args:
%   eeg_data - data matrix. The size of eeg_data should be nComponents x 
%              (nTrials*nImages)
%   labels - labels vector. The size of labels should be (nTrials*nImages)
%   num_permutations (optional) - how many permutations to randomly select
%                                 train and test data matrix.
% Output Args:
%   dissimilarities - the dissimilarity matrix

    num_dim = length(size(eeg_data));
    assert(num_dim == 2);
    assert(size(eeg_data,2) == length(labels));
    
    if nargin < 3 || isempty(num_permutations)
        num_permutations = 10;
    end
    
    num_images = max(labels);
    num_features = size(eeg_data,1);
    dissimilarities = nan(num_permutations, num_images, num_images);
    for p=1:num_permutations
        rng(p);
        for i=1:num_images

            img1_data = squeeze(eeg_data(:,labels==i));
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

            for j=1:num_images
    
                img2_data = squeeze(eeg_data(:,labels==j));
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

            end % second image
        end % first image
    end % permutations
end % function


