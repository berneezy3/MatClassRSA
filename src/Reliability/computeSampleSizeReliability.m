function [reliabilities] = computeSampleSizeReliability(X, Y, timepoint_idx, ...
    num_trials_per_half, num_permutations, num_trial_permutations, rand_seed)
%---------------------------------------------------------------------------------------------
%  [reliabilities] = computeSampleSizeReliability(X, Y, timepoint_idx, ...
%                       num_trials_per_half, num_permutations, num_trial_permutations)
%---------------------------------------------------------------------------------------------
%
% Computes reliabilities of data over subsets of trials for each component for a specific
% time point. Typically, one would aggregate the trials across participants and provide the
% aggregated data as input into this function.
%
% Input Args:
%   X - data matrix. X is a 3D matrix, it is assumed to be of size 
%              nSpace x nTime x nTrial. If X is a 2D matrix, it is assumed to be of 
%              size nTrial x nFeature.
%   Y - labels vector. The length of Y should be nTrial.
%   timepoint_idx - Time (feature) sample index to use in computing reliability for a subset
%                   of trials.
%   num_trials_per_half (optional) - a vector of how many trials in a split half to
%                                    use for reliability computation. (e.g. [1,2,3] would
%                                    correspond to using 2, 4 and 6 trials in the reliability
%                                    computation). If not entered, defaults to [1], meaning
%                                    that it uses 2 trials in total.
%   num_permutations (optional) - how many permutations to split the trials for split half
%                                 reliability? This is for inner loop to compute reliability.
%                                 If not entered, this defaults to 10.
%   num_trial_permutations (optional) - how many times to choose trials in the data set
%                                       to compute reliability? This is for the outer loop.
%                                       This is useful if we wanted to compute the variance
%                                       of the reliability across random draws of the trials.
%                                       If not entered, this defaults to 10.
%   rand_seed (optional) - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister'). 
%       --- Acceptable specifications for rand_seed ---
%           - Single acceptable rng specification input (e.g., 1, 
%               'default', 'shuffle'); in these cases, the generator will 
%               be set to 'twister'.
%           - Dual-argument specifications as either a 2-element cell 
%               array (e.g., {'shuffle', 'twister'}) or string array 
%               (e.g., ["shuffle", "twister"].
%           - rng struct as assigned by rand_seed = rng.
%
% Output Args:
%   reliabilities - If input matrix was 3D, dimensions are: num_trial_permutations x 
%                   length(num_trials_per_half) x nSpace. If input matrix was 2D, dimensions 
%                   are: num_trial_permutations x length(num_trials_per_half)

assert(length(size(X)) == 3 || length(size(X)) == 2, 'Invalid number of dimensions in the data.');

% If 3D matrix entered, dimensions are: space x time x trial
% We will permute so that it becomes space x trial x time
if length(size(X)) == 3
    X = permute(X, [1,3,2]);
end

% If 2D matrix entered, dimensions are: trial x time
% We will add a singleton dimension in the front for space so it
% becomes space x trial x time.
if length(size(X)) == 2 % Trial by time
    temp = X; clear X
    X(1,:,:) = temp; clear temp
end

assert(size(X, 2) == length(Y), 'Length of labels vector does not match number of trials in the data.');

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

% Set random number generator
if nargin < 7 || isempty(rand_seed), setUserSpecifiedRng();
else, setUserSpecifiedRng(rand_seed);
end

num_components = size(X, 1);
total_trials = size(X, 2);
num_trial_subsets = length(num_trials_per_half);
num_images = length(unique(Y));

reliabilities = zeros(num_trial_permutations, num_trial_subsets, num_components);
time_data = squeeze(X(:,:,timepoint_idx));
for k=1:num_trial_permutations

    % Shuffle data and labels
    random_indices = randperm(total_trials);
    shuffled_data = time_data(:,random_indices);
    shuffled_labels = Y(random_indices);

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

function [new_data, new_labels] = acquire_data(X, Y, num_trials_to_use, num_images)
% Acquires num_trials_to_use trials for each stimulus
% X: (num_components, num_trials)
% Returns (num_components, num_trials_to_use*num_images) and label vector associated with it
assert(length(Y) == size(X, 2), 'Length of labels vector does not match number of trials in the data.');

unique_labels = unique(Y);
assert(length(unique_labels) == num_images, 'Mismatch in number of unique images number of unique labels.')

num_components = size(X, 1);
new_data = zeros(num_components, num_trials_to_use*num_images);
new_labels = zeros(num_trials_to_use*num_images,1);

for i=1:num_images
    curr_label = unique_labels(i);
    idx_to_use = find(Y==curr_label);
    idx_to_use = idx_to_use(1:num_trials_to_use);
    
    start_idx = (i-1) * num_trials_to_use + 1;
    end_idx = i * num_trials_to_use;
    new_data(:,start_idx:end_idx) = X(:,idx_to_use);
    new_labels(start_idx:end_idx) = curr_label;
end
end


