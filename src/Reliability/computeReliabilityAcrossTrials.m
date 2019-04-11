function [reliabilities] = computeReliabilityAcrossTrials(eeg_data, labels, timepoint_idx, num_trials_per_half, num_permutations, num_trial_permutations)
%-----------------------------------------------------------------------------
%  [reliabilities] = computeReliabilityAcrossTrials(eeg_data, labels, ...
%                   timepoint_idx, num_trials_per_half, num_permutations, ...
%                   num_trials_permutations)
%-----------------------------------------------------------------------------
% Nathan Kong
%
% Computes reliabilities of data over subsets of trials for each component.
% Input Args:
%   eeg_data - data matrix. The size of eeg_data should be (nTrials*nImages) x 
%              nTimepoints x nComponents
%   labels - labels vector. The size of labels should be (nTrials*nImages)
%   timepoint_idx - timepoint to use in computing reliability for a subset of trials
%   num_trials_per_half (optional) - a vector of how many trials in a split half to
%                                    use for reliability computation.
%                                    (e.g. [1,2,3] would correspond to using 2,
%                                    4 and 6 trials in the reliability computation       
%   num_permutations (optional) - how many permutations to split the trials for split
%                                 half reliability?
%   num_trial_permutations (optional) - how many times to choose trials in the
%                                       dataset to compute reliability?
%
% Output Args:
%   reliabilities - dimensions are: num_trial_permutations x length(num_trials_per_half) x ...
%                                   num_components)

    assert(size(eeg_data, 1) == length(labels));

    if nargin < 4
        num_trials_per_half = 1;
        num_permutations = 10;
    end
    if nargin < 5
        num_permutations = 10;
    end
    if nargin < 6
        num_trial_permutations = 10;
    end

    num_images = max(unique(labels));
    total_trials = size(eeg_data, 1);
    num_components = size(eeg_data, 3);
    num_trial_subsets = length(num_trials_per_half);

    reliabilities = zeros(num_trial_permutations, num_trial_subsets, num_components);
    time_data = squeeze(eeg_data(:,timepoint_idx,:));
    for k=1:num_trial_permutations
        % Shuffle data and labels
        rng(k);
        random_indices = randperm(total_trials);
        shuffled_data = time_data(random_indices,:);
        shuffled_labels = labels(random_indices);
        for i=1:num_trial_subsets
            fprintf('Permutation %d: %d trials in subset\n', k, num_trials_per_half(i)*2);
    
            % Acquire trials for each stimulus
            num_trials_to_use = num_trials_per_half(i)*2;
            [curr_data, curr_data_labels] = acquire_data(shuffled_data, shuffled_labels, num_trials_to_use, num_images);
            rel = computeReliability(curr_data, curr_data_labels, num_permutations);
            reliabilities(k,i,:) = mean(rel, 1);
        end
    end
end

function [new_data, new_labels] = acquire_data(eeg_data, labels, num_trials_to_use, num_images)
% Acquires num_trials_to_use trials for each stimulus
% eeg_data: (num_trials, num_components)
% Returns (num_trials_to_use*num_images,num_components) and label vector
    assert(length(labels) == size(eeg_data,1));
    num_components = size(eeg_data, 2);
    new_data = zeros(num_trials_to_use*num_images, num_components);
    new_labels = zeros(num_trials_to_use*num_images,1);
    for i=1:num_images
        idx_to_use = find(labels==i);
        idx_to_use = idx_to_use(1:num_trials_to_use);

        start_idx = (i-1) * num_trials_to_use + 1;
        end_idx = i * num_trials_to_use;
        new_data(start_idx:end_idx,:) = eeg_data(idx_to_use,:);
        new_labels(start_idx:end_idx) = i;
    end
end


