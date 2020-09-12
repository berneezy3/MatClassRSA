function [rels] = computeReliability(data, labels, num_permutations)
%-------------------------------------------------------------------
% (c) Bernard Wang, Nathan Kong, Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%--------------------------------------------------------------------------------------------
%  [rels] = computeReliability(data, labels, num_permutations)
%--------------------------------------------------------------------------------------------
%
% This function computes the component-wise reliability of a data matrix, which has
% information about a specific time point.  The functions in this file are used
% in conjunction with:
%   - computeSampleSizeReliability.m
%   - computeSpaceTimeReliability.m
%
% Input Args:
%   data - 3D data matrix. The dimensions of the data matrix are: nSpace x nTrial
%   labels - labels vector. The length of labels should be equal to nTrials.
%   num_permutations - how many permutations to split the trials for split half reliability.
%
% Output Args:
%   rels - reliability for each electrode at a particular time. The dimensions of
%          the results matrix is: num_permutations x num_components


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

    assert(size(data, 2) == length(labels), 'Mismatch been the number of trials in the data and the length of the labels vector.');

    num_components = size(data, 1);
    rels = zeros(num_components, num_permutations);
    for e=1:num_components
        e_rels = zeros(1,num_permutations);
        e_data = convertToSquareMatrix(squeeze(data(e,:)), labels);
        % Data shape: (num_images, num_trials)
        num_trials = size(e_data, 2);
        half_idx = num_trials / 2;
        full_idx = num_trials;
        for p=1:num_permutations
            random_indices = randperm(num_trials);
            shuffled_data = e_data(:,random_indices);
            half_1 = mean(shuffled_data(:,1:half_idx), 2);
            half_2 = mean(shuffled_data(:,half_idx+1:full_idx), 2);
            assert(size(half_1,2) == 1);
            assert(size(half_2,2) == 1);
            correlation = corr(half_1, half_2);
            % Spearman-Brown correction
            corrected_correlation = 2.0*correlation / (1.0+correlation);
            e_rels(p) = corrected_correlation;
        end
        rels(e,:) = e_rels;
    end
    rels = rels';
end

% Internal function. Should not be called externally.
function [data_matrix] = convertToSquareMatrix(data, labels)
% Converts a trials vector into a square matrix of shape (num_images, num_trials)
% If number of trials uneven for all images, take the use the smallest number
% of trials available for a stimulus.
    assert(length(data) == length(labels));
    unique_labels = unique(labels);
    num_images = length(unique_labels);
    min_trials = Inf;
    for i=1:num_images
        curr_label = unique_labels(i);
        num_trials = sum(labels==curr_label);
        if num_trials < min_trials
            min_trials = num_trials;
        end
    end
    data_matrix = zeros(num_images, min_trials);
    for i=1:num_images
        curr_label = unique_labels(i);
        curr_data = data(labels==curr_label);
        data_matrix(i,:) = curr_data(1:min_trials);
    end
end


