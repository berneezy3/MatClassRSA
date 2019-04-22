function [norm_eeg_data, sigma_inv] = noiseNormalization(eeg_data, labels)
%-------------------------------------------------------------------
%  [norm_eeg_data, sigma_inv] = noiseNormalization(eeg_data, labels)
%-------------------------------------------------------------------
% Nathan Kong
%
% Function to perform multivariate noise normalization on time varying data.
% It depends on an external function 'cov1para', which needs to be in the same
% directory as this function.
% Input Args:
%   eeg_data - data matrix. The size of eeg_data should be nComponents x nTimepoints
%              x (nTrials*nImages)
%   labels - labels vector. The size of labels should be (nTrials*nImages)
% Output Args:
%   norm_eeg_data - the data matrix after noise normalization is applied.
%   sigma_inv - inverse of the square root of the covariance matrix.

    num_components = size(eeg_data, 1);
    num_images = max(labels);
    num_timepoints = size(eeg_data, 2);
    total_trials = size(eeg_data, 3);

    % This is probably not the best in terms of memory
    norm_eeg_data = nan(num_components, num_timepoints, total_trials);

    all_image_covs = nan(num_images, num_components, num_components);
    for i=1:num_images
        all_time_covs = nan(num_timepoints, num_components, num_components);
        for j=1:num_timepoints
            all_time_covs(j,:,:) = cov1para(squeeze(eeg_data(:,j,labels==i))');
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
end


