function [reliabilities] = computeSampleSizeReliability(eeg_data, labels, timepoint_idx, ...
    num_trials_per_half, num_permutations, num_trial_permutations, rand_seed)
%---------------------------------------------------------------------------------------------
%  [reliabilities] = computeSampleSizeReliability(eeg_data, labels, timepoint_idx, ...
%                       num_trials_per_half, num_permutations, num_trial_permutations)
%---------------------------------------------------------------------------------------------
%
% Computes reliabilities of data over subsets of trials for each component for a specific
% time point. Typically, one would aggregate the trials across participants and provide the
% aggregated data as input into this function.
%
% Input Args:
%   eeg_data - data matrix. The eeg_data is a 3D matrix, it is assumed to
%              be of size nSpace x nTime x nTrial. If eeg_data is a 2D
%              matrix, it is assumed to be of size nTrial x nFeature.
%   labels - labels vector. The length of labels should be nTrial.
%   timepoint_idx - Time (feature) sample index to use in computing reliability for a subset
%                   of trials.
%   num_trials_per_half (optional) - a vector of how many trials in a split half to
%                                    use for reliability computation. (e.g. [1,2,3] would
%                                    correspond to using 2, 4 and 6 trials in the reliability
%                                    computation). If not entererd, defaults to [1], meaning
%                                    that it uses 2 trials in total.
%   num_permutations (optional) - how many permutations to split the trials for split half
%                                 reliability? This is for inner loop to compute reliability.
%                                 If not entered, this defaults to 10.
%   num_trial_permutations (optional) - how many times to choose trials in the data set
%                                       to compute reliability? This is for the outer loop.
%                                       This is useful if we wanted to compute the variance
%                                       of the reliability across random draws of the trials.
%                                       If not entered, this defaults to 10.
%   rand_seed (optional) - random seed for reproducibility. If not entered,
%                          this defaults to 'shuffle'.
%
% Output Args:
%   reliabilities - If input matrix was 3D, dimensions are: num_trial_permutations x 
%                   length(num_trials_per_half) x nSpace. If input matrix was 2D, dimensions 
%                   are: num_trial_permutations x length(num_trials_per_half)

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
    dim1 = size(eeg_data,1);
    dim2 = size(eeg_data,2);
    eeg_data = reshape(eeg_data, [1,dim1,dim2]);
end

assert(size(eeg_data, 2) == length(labels), 'Length of labels vector does not match number of trials in the data.');

if nargin < 4
    num_trials_per_half = 1;
    num_permutations = 10;
end
if nargin < 5 || isempty(num_permutations)
    num_permutations = 10;
end
if nargin < 6 || isempty(num_trial_permutations)
    num_trial_permutations = 10;
end

% Set random seed
if nargin < 7 || isempty(rand_seed)
    rand_seed = 'shuffle';
end
rng(rand_seed);

num_components = size(eeg_data, 1);
total_trials = size(eeg_data, 2);
num_trial_subsets = length(num_trials_per_half);
num_images = length(unique(labels));

reliabilities = zeros(num_trial_permutations, num_trial_subsets, num_components);
time_data = squeeze(eeg_data(:,:,timepoint_idx));
for k=1:num_trial_permutations

    % Shuffle data and labels
    random_indices = randperm(total_trials);
    shuffled_data = time_data(:,random_indices);
    shuffled_labels = labels(random_indices);

    for i=1:num_trial_subsets
        fprintf('Permutation %d: %d trials in subset\n', k, num_trials_per_half(i)*2);
        
        % Acquire trials for each stimulus
        num_trials_to_use = num_trials_per_half(i)*2;
        [curr_data, curr_data_labels] = acquire_data( ...
            shuffled_data, ...
            shuffled_labels, ...
            num_trials_to_use, ...
            num_images ...
        );
        rel = computeReliability(curr_data, curr_data_labels, num_permutations);
        reliabilities(k,i,:) = mean(rel, 1);
    end % Trial subsets
end % Random permutations of trials

end

function [new_data, new_labels] = acquire_data(eeg_data, labels, num_trials_to_use, num_images)
% Acquires num_trials_to_use trials for each stimulus
% eeg_data: (num_components, num_trials)
% Returns (num_components, num_trials_to_use*num_images) and label vector associated with it
assert(length(labels) == size(eeg_data, 2), 'Length of labels vector does not match number of trials in the data.');

unique_labels = unique(labels);
assert(length(unique_labels) == num_images, 'Mismatch in number of unique images number of unique labels.')

num_components = size(eeg_data, 1);
new_data = zeros(num_components, num_trials_to_use*num_images);
new_labels = zeros(num_trials_to_use*num_images,1);

for i=1:num_images
    curr_label = unique_labels(i);
    idx_to_use = find(labels==curr_label);
    idx_to_use = idx_to_use(1:num_trials_to_use);
    
    start_idx = (i-1) * num_trials_to_use + 1;
    end_idx = i * num_trials_to_use;
    new_data(:,start_idx:end_idx) = eeg_data(:,idx_to_use);
    new_labels(start_idx:end_idx) = curr_label;
end
end


