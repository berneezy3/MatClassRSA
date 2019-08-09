function [reliabilities] = computeSpaceTimeReliability(eeg_data, labels, num_permutations, rand_seed)
%------------------------------------------------------------------------------------------
%  [reliabilities] = computeSpaceTimeReliability(eeg_data, labels, num_permutations)
%------------------------------------------------------------------------------------------
%
% Returns reliabilities computed for each component across time. With the resulting
% data matrix, one can take the mean along the third dimension (the components axis)
% and this will tell you the average reliability across components at each time point.
% On the other hand, if one takes the mean across the first dimension (the time axis),
% one will be able to see how reliable each component is across time (on average).
%
% Input Args:
%   eeg_data - data matrix. 3D data matrices are assumed to be nSpace x nTime x
%              nTrial.  If the data matrix is 2D, it is assumed to be nTrial x 
%              nFeature.
%   labels - labels vector. The length of labels should be equal to nTrials.
%   num_permutations (optional) - how many permutations to split the trials for split half
%                                 reliability. If not entered, this defaults to 10.
%   rand_seed (optional) - random seed for reproducibility. If not entered,
%                          this defaults to 'shuffle'.
%
% Output Args:
%   reliabilities - reliability for each electrode across time. The dimensions of
%                   this matrix are: nSpace x nTime x nPermutations if a 3D matrix was
%                   provided.  If a 2D matrix was provided, the dimensions of the results
%                   are: nTime x nSpace. You would typically average across the permutations 
%                   dimension.

% If 3D matrix entered, dimensions are: space x time x trial
% We will permute so that it becomes space x trial x time
if length(size(eeg_data)) == 3
    eeg_data = permute(eeg_data, [1,3,2]);
end

% If 2D matrix entered, dimensions are: trial x time
% We will permute so that it becomes time x trial and add
% a singleton dimension in the front for space.
if length(size(eeg_data)) == 2
    eeg_data = permute(eeg_data, [2,1]);
    [dim1, dim2] = size(eeg_data);
    eeg_data = reshape(eeg_data, [1,dim1,dim2]);
end

if nargin < 3 || isempty(num_permutations)
    num_permutations = 10;
end

% Set random seed
if nargin < 4 || isempty(rand_seed)
    rand_seed = 'shuffle';
end
rng(rand_seed);

num_components = size(eeg_data, 1);
num_timepoints = size(eeg_data, 3);

reliabilities = zeros(num_timepoints, num_permutations, num_components);
for t=1:num_timepoints
    fprintf('Timepoint %d\n', t);
    curr_data = squeeze(eeg_data(:,:,t));
    rels = computeReliability(curr_data, labels, num_permutations);
    assert(isequal(size(rels), [num_permutations, num_components]));
    reliabilities(t,:,:) = rels;
end

% This means a 3D data matrix was provided. Permute the results matrix 
% so that the dimensions are: space x time x permutations
if num_components > 1
    reliabilities = permute(reliabilities, [3,1,2]);
end

end


