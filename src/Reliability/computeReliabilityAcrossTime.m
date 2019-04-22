function [reliabilities] = computeReliabilityAcrossTime(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
%  [reliabilities] = computeReliabilityAcrossTime(eeg_data, labels, num_permutations)
%-------------------------------------------------------------------
% Nathan Kong
%
% Returns reliabilities computed for each component across time.
% Input Args:
%   eeg_data - data matrix. The size of eeg_data should be (nTrials*nImages) x 
%              nTimepoints x nComponents
%   labels - labels vector. The size of labels should be (nTrials*nImages)
%   num_permutations (optional) - how many permutations to split the trials for
%                                 split half reliability
%
% Output Args:
%   reliabilities - reliability for each electrode across time

    if nargin < 3 || isempty(num_permutations)
        num_permutations = 10;
    end

    num_timepoints = size(eeg_data, 2);
    num_components = size(eeg_data, 3);

    reliabilities = zeros(num_timepoints, num_permutations, num_components);
    for t=1:num_timepoints
        fprintf('Timepoint %d\n', t);
        curr_data = squeeze(eeg_data(:,t,:));
        rels = computeReliability(curr_data, labels, num_permutations);
        assert(isequal(size(rels), [num_permutations, num_components]));
        reliabilities(t,:,:) = rels;
    end
end


