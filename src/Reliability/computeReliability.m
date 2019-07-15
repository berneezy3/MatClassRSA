function [rels] = computeReliability(data, labels, num_permutations)
% data is of shape: (num_trials, num_components)
% Should return reliabilities of shape (num_permutations, num_components)
    num_components = size(data, 2);
    rels = zeros(num_components, num_permutations);
    for e=1:num_components
        e_rels = zeros(1,num_permutations);
        e_data = convertToSquareMatrix(squeeze(data(:,e)), labels);
        % Data shape: (num_images, num_trials)
        num_trials = size(e_data, 2);
        half_idx = num_trials / 2;
        full_idx = num_trials;
        for p=1:num_permutations
            rng(p);
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
    num_images = max(unique(labels));
    min_trials = Inf;
    for i=1:num_images
        num_trials = sum(labels==i);
        if num_trials < min_trials
            min_trials = num_trials;
        end
    end
    data_matrix = zeros(num_images, min_trials);
    for i=1:num_images
        data_matrix(i,:) = data(labels==i);
    end
end


