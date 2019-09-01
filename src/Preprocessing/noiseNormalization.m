function [norm_eeg_data, sigma_inv] = noiseNormalization(eeg_data, labels)
%---------------------------------------------------------------------------
%  [norm_eeg_data, sigma_inv] = noiseNormalization(eeg_data, labels)
%---------------------------------------------------------------------------
%
% Function to perform multivariate noise normalization on time varying data.
% It depends on an external function 'cov1para', which needs to be in the 
% path.
%
% Input Args:
%   eeg_data - The data matrix. Can be a 3D matrix (space x time x trial)
%       or a 2D matrix (trial x feature).
%   labels - Labels vector. The length of this vector should correspond to
%       the length, along the trial dimension, of the input data.
% Output Args:
%   norm_eeg_data - Data matrix after noise normalization is applied. It
%       will be the same size as the input data matrix.
%   sigma_inv - Inverse of the square root of the covariance matrix.

    assert(isvector(labels), '`labels` is not a vector.');
    assert(length(size(eeg_data)) == 3 || length(size(eeg_data)) == 2, 'Invalid number of dimensions in the data.');

    % If 2D matrix entered, dimensions are: trial x time
    % We will permute so that it becomes time x trial and add
    % a singleton dimension in the front for space.
    if length(size(eeg_data)) == 2
        num_dim = 2;
        eeg_data = permute(eeg_data, [2,1]);
        dim1 = size(eeg_data,1);
        dim2 = size(eeg_data,2);
        eeg_data = reshape(eeg_data, [1,dim1,dim2]);
    elseif ndims(eeg_data)
        num_dim = 3;
    end
    assert(size(eeg_data, 3) == length(labels), 'Length of labels vector does not match number of trials in the data.');
    
    num_components = size(eeg_data, 1);
    num_timepoints = size(eeg_data, 2);
    total_trials = size(eeg_data, 3);

    unique_labels = unique(labels);
    num_images = length(unique_labels);

    % This is probably not the best in terms of memory
    norm_eeg_data = nan(num_components, num_timepoints, total_trials);

    all_image_covs = nan(num_images, num_components, num_components);
    for i=1:num_images
        all_time_covs = nan(num_timepoints, num_components, num_components);
        for j=1:num_timepoints
            curr_label = unique_labels(i);
%             keyboard
            all_time_covs(j,:,:) = cov1para(squeeze(eeg_data(:,j,labels==curr_label))');
        end
        % Average covariances across time
        all_image_covs(i,:,:) = squeeze(mean(all_time_covs,1));
    end

    % Average covariances across images
    sigma = squeeze(mean(all_image_covs, 1));
    sigma_inv = sigma^(-0.5);

    for t=1:num_timepoints
        weighted_data = sigma_inv * squeeze(eeg_data(:,t,:));
        norm_eeg_data(:,t,:) = weighted_data;
    end

    % If the 2D data were provided, permute back to original dimensions
    if num_dim == 2
        norm_eeg_data = permute(norm_eeg_data, [3,2,1]);
    end

end


