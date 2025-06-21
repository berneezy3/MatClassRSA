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
%
% This code was adapted from a code tutorial provided by Guggenmos et al.
% (2018):
% - https://github.com/m-guggenmos/megmvpa/blob/master/tutorial_matlab/matlab_distance.ipynb
% - Related publication: Guggenmos, M., Sterzer, P., & Cichy, R. M. (2018). 
%   Multivariate pattern analysis for MEG: A comparison of dissimilarity 
%   measures. Neuroimage, 173, 434-447. DOI: 10.1016/j.neuroimage.2018.02.044
%
% MatClassRSA dependencies: Utils.cov1para()

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


