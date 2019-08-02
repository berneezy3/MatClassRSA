function [reliabilities] = computeSpaceTimeReliability(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
%  [reliabilities] = computeSpaceTimeReliability(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
%
% Returns reliabilities computed for each component across time. With the resulting
% data matrix, one can take the mean along the third dimension (the components axis)
% and this will tell you the average reliability across components at each time point.
% On the other hand, if one takes the mean across the first dimension (the time axis),
% one will be able to see how reliable each component is across time (on average).
%
% Input Args:
%   eeg_data - data matrix. 3D eeg_data matrices are assumed to be nSpace x
%              nTime x nTrial.  If the size of eeg_data is 2D, it is
%              assumed to be nTrial x nFeature.
%   labels - labels vector. The length of labels should be nTrials.
%   num_permutations (optional) - how many permutations to split the trials for
%              split half reliability. If not entered, defaults to 10.
%
% Output Args:
%   reliabilities - reliability for each electrode across time. The dimensions of
%               this matrix are: nTime x nPermutations x nSpace.
%               You would typically average across the permutations dimension.

% TODO: If 3D matrix is entered, permute dimensions accordingly. If 2D matrix is entered,
% check to make sure dimensions make sense.

% TODO: Make sure output data dimensions correspond to input data
% dimensions. 3D input --> space x time x permutations. 2D input --> time x
% permutations.

% TODO: Add 4th optional input for rngSeed. If not entered or empty, set it
% to 'shuffle'. If entered, replace rng line below.
rngSeed = 2;

if nargin < 3 || isempty(num_permutations)
    num_permutations = 10;
end


% Add singleton third dimension if 2D data are input
if length(size(eeg_data)) == 2
    [dim1, dim2] = size(eeg_data);
    eeg_data = reshape(eeg_data, [1,dim1,dim2]);
end

num_timepoints = size(eeg_data, 3);
num_components = size(eeg_data, 1);

rng(rngSeed) % <--- TODO: fix/check this!

reliabilities = zeros(num_timepoints, num_permutations, num_components);
for t=1:num_timepoints
    fprintf('Timepoint %d\n', t);
    curr_data = squeeze(eeg_data(:,:,t));
    rels = computeReliability(curr_data, labels, num_permutations);
    assert(isequal(size(rels), [num_permutations, num_components]));
    reliabilities(t,:,:) = rels;
end
end


