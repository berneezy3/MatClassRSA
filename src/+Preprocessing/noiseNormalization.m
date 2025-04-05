function [normData, sigmaInv] = noiseNormalization(X, Y)
%---------------------------------------------------------------------------
%  [normData, sigmaInv] = Preprocessing.noiseNormalization(X, Y)
%---------------------------------------------------------------------------
%
% Function to perform multivariate noise normalization on time varying data.
% It depends on an external function 'cov1para', which needs to be in the 
% path.
%
% REQUIRED INPUTS:
%   X - The data matrix. Can be a 3D matrix (space x time x trial)
%       or a 2D matrix (trial x feature).
%   Y - Labels vector. The length of this vector should correspond to
%       the length, along the trial dimension, of the input data.
% OUTPUTS:
%   normData - Data matrix after noise normalization is applied. It
%       will be the same size as the input data matrix.
%   sigmaInv - Inverse of the square root of the covariance matrix.

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2019 Bernard C. Wang, Nathan C. L. Kong, Anthony M. Norcia, 
% and Blair Kaneshiro
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
%
% MatClassRSA Dependencies: Utils.cov1para()

    assert(isvector(Y), '`Y` is not a vector.');
    assert(length(size(X)) == 3 || length(size(X)) == 2, 'Invalid number of dimensions in the data.');

    % If 2D matrix entered, dimensions are: trial x time
    % We will permute so that it becomes time x trial and add
    % a singleton dimension in the front for space.
    if length(size(X)) == 2
        num_dim = 2;
        X = permute(X, [2,1]);
        dim1 = size(X,1);
        dim2 = size(X,2);
        X = reshape(X, [1,dim1,dim2]);
    elseif ndims(X)
        num_dim = 3;
    end
    assert(size(X, 3) == length(Y), 'Length of labels vector does not match number of trials in the data.');
    
    num_components = size(X, 1);
    num_timepoints = size(X, 2);
    total_trials = size(X, 3);

    unique_labels = unique(Y);
    num_images = length(unique_labels);

    % This is probably not the best in terms of memory
    normData = nan(num_components, num_timepoints, total_trials);

    all_image_covs = nan(num_images, num_components, num_components);
    for i=1:num_images
        all_time_covs = nan(num_timepoints, num_components, num_components);
        for j=1:num_timepoints
            curr_label = unique_labels(i);
            if num_components > 1
                all_time_covs(j,:,:) = Utils.cov1para(squeeze(X(:,j,Y==curr_label))');
            elseif num_components == 1
                all_time_covs(j,:,:) = Utils.cov1para(squeeze(X(:,j,Y==curr_label)));
            else
                assert(0, 'Condition should not be reached.');
            end
        end
        % Average covariances across time
        all_image_covs(i,:,:) = squeeze(mean(all_time_covs,1));
    end

    % Average covariances across images
    sigma = squeeze(mean(all_image_covs, 1));
    sigmaInv = sigma^(-0.5);

    for t=1:num_timepoints
        weighted_data = sigmaInv * squeeze(X(:,t,:));
        normData(:,t,:) = weighted_data;
    end

    % If the 2D data were provided, permute back to original dimensions
    if num_dim == 2
        normData = permute(normData, [3,2,1]);
    end

end


