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
%   eeg_data - data matrix. The size of eeg_data should be nComponents x 
%              (nTrials*nImages) x nTimepoints.  If the size of eeg_data is:
%              (nTrials*nImages) x nTimepoints, the function automatically adds
%              a singleton dimension at the beginning.
%   labels - labels vector. The size of labels should be (nTrials*nImages)
%   num_permutations (optional) - how many permutations to split the trials for
%                                 split half reliability
%
% Output Args:
%   reliabilities - reliability for each electrode across time. The dimensions of
%                   this matrix is: nTimepoints x nPermutations x nComponents.
%                   You would typically average across the permutations dimension.

    if nargin < 3 || isempty(num_permutations)
        num_permutations = 10;
    end

    if length(size(eeg_data)) == 2
        dim1 = size(eeg_data,1);
        dim2 = size(eeg_data,2);
        eeg_data = reshape(eeg_data, [1,dim1,dim2]);
    end

    num_timepoints = size(eeg_data, 3);
    num_components = size(eeg_data, 1);

    reliabilities = zeros(num_timepoints, num_permutations, num_components);
    for t=1:num_timepoints
        fprintf('Timepoint %d\n', t);
        curr_data = squeeze(eeg_data(:,:,t));
        rels = computeReliability(curr_data, labels, num_permutations);
        assert(isequal(size(rels), [num_permutations, num_components]));
        reliabilities(t,:,:) = rels;
    end
end


