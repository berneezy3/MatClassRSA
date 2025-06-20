function [rels] = computeReliability(data, labels, num_permutations)
%-------------------------------------------------------------------
%  [rels] = computeReliability(data, labels, num_permutations)
%-------------------------------------------------------------------
%
% This function computes the component-wise reliability of an input data 
% matrix containing information about a specific time point.  The functions 
% in this file are used in conjunction with:
%   - computeSampleSizeReliability.m
%   - computeSpaceTimeReliability.m
%
% REQUIRED INPUTS:
%   data - Data matrix. The dimensions of the data matrix are: nSpace x nTrial
%   labels - labels vector. The length of labels should be equal to nTrials.
%   num_permutations - how many permutations to split the trials for split half reliability.
%
% OUTPUTS:
%   rels - reliability for each electrode at a particular time. The dimensions of
%          the results matrix is: num_permutations x num_components

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


